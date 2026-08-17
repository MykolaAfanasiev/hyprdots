#!/usr/bin/env python3

from __future__ import annotations

import math
import subprocess
import time

from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo


ROOT = Path(__file__).resolve().parent.parent

LOCATION_FILE = ROOT / "location.conf"
SCHEDULE_FILE = ROOT / "schedule.conf"


def load_config(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}

    with path.open(encoding="utf-8") as file:
        for line_number, raw_line in enumerate(file, start=1):
            line = raw_line.strip()

            if not line or line.startswith("#"):
                continue

            if "=" not in line:
                raise ValueError(
                    f"Invalid config line {path}:{line_number}: {line!r}"
                )

            key, value = line.split("=", 1)
            result[key.strip()] = value.strip().strip("'\"")

    return result


def get_local_timezone():
    try:
        localtime = Path("/etc/localtime").resolve()
        prefix = "/usr/share/zoneinfo/"
        path = str(localtime)

        if path.startswith(prefix):
            return ZoneInfo(path[len(prefix):])
    except (OSError, ValueError):
        pass

    return datetime.now().astimezone().tzinfo


def calculate_sun_times(
    day: date,
    latitude: float,
    longitude: float,
    local_tz,
):
    day_of_year = day.timetuple().tm_yday

    gamma = 2.0 * math.pi / 365.0 * (day_of_year - 1)

    equation_of_time = 229.18 * (
        0.000075
        + 0.001868 * math.cos(gamma)
        - 0.032077 * math.sin(gamma)
        - 0.014615 * math.cos(2 * gamma)
        - 0.040849 * math.sin(2 * gamma)
    )

    declination = (
        0.006918
        - 0.399912 * math.cos(gamma)
        + 0.070257 * math.sin(gamma)
        - 0.006758 * math.cos(2 * gamma)
        + 0.000907 * math.sin(2 * gamma)
        - 0.002697 * math.cos(3 * gamma)
        + 0.00148 * math.sin(3 * gamma)
    )

    latitude_rad = math.radians(latitude)
    zenith = math.radians(90.833)

    cos_hour_angle = (
        math.cos(zenith)
        / (math.cos(latitude_rad) * math.cos(declination))
        - math.tan(latitude_rad) * math.tan(declination)
    )

    cos_hour_angle = max(-1.0, min(1.0, cos_hour_angle))
    hour_angle = math.degrees(math.acos(cos_hour_angle))

    solar_noon = 720 - 4 * longitude - equation_of_time
    sunrise_minutes = solar_noon - 4 * hour_angle
    sunset_minutes = solar_noon + 4 * hour_angle

    midnight_utc = datetime(
        day.year,
        day.month,
        day.day,
        tzinfo=timezone.utc,
    )

    sunrise = (
        midnight_utc + timedelta(minutes=sunrise_minutes)
    ).astimezone(local_tz)

    sunset = (
        midnight_utc + timedelta(minutes=sunset_minutes)
    ).astimezone(local_tz)

    return sunrise, sunset


def interpolate(
    start_value: float,
    end_value: float,
    progress: float,
) -> float:
    progress = max(0.0, min(1.0, progress))
    return start_value + (end_value - start_value) * progress


def transition_progress(
    now: datetime,
    start: datetime,
    end: datetime,
) -> float:
    total = (end - start).total_seconds()

    if total <= 0:
        return 1.0

    return (now - start).total_seconds() / total


class HyprsunsetController:
    def __init__(self) -> None:
        self._last_state: tuple[str, int | None] | None = None

    def _run(self, state: tuple[str, int | None], *args: str) -> None:
        if state == self._last_state:
            return

        result = subprocess.run(
            ["hyprctl", "hyprsunset", *args],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )

        if result.returncode == 0:
            self._last_state = state

    def identity(self) -> None:
        self._run(("identity", None), "identity")

    def temperature(self, value: int) -> None:
        self._run(("temperature", value), "temperature", str(value))


def main() -> None:
    location = load_config(LOCATION_FILE)
    schedule = load_config(SCHEDULE_FILE)

    latitude = float(location["LATITUDE"])
    longitude = float(location["LONGITUDE"])

    if not -90 <= latitude <= 90:
        raise ValueError("LATITUDE must be between -90 and 90")

    if not -180 <= longitude <= 180:
        raise ValueError("LONGITUDE must be between -180 and 180")

    day_temperature = int(schedule.get("DAY_TEMPERATURE", "6500"))
    night_temperature = int(schedule.get("NIGHT_TEMPERATURE", "3500"))
    sunrise_before = int(schedule.get("SUNRISE_BEFORE", "90"))
    sunrise_after = int(schedule.get("SUNRISE_AFTER", "30"))
    sunset_before = int(schedule.get("SUNSET_BEFORE", "60"))
    sunset_after = int(schedule.get("SUNSET_AFTER", "120"))
    update_interval = int(schedule.get("UPDATE_INTERVAL", "60"))

    if update_interval < 1:
        raise ValueError("UPDATE_INTERVAL must be at least 1 second")

    local_tz = get_local_timezone()
    controller = HyprsunsetController()
    logged_day: date | None = None

    while True:
        now = datetime.now(local_tz)

        sunrise, sunset = calculate_sun_times(
            now.date(),
            latitude,
            longitude,
            local_tz,
        )

        morning_start = sunrise - timedelta(minutes=sunrise_before)
        morning_end = sunrise + timedelta(minutes=sunrise_after)
        evening_start = sunset - timedelta(minutes=sunset_before)
        evening_end = sunset + timedelta(minutes=sunset_after)

        if logged_day != now.date():
            print(
                f"[hyprsunset] Sunrise: {sunrise:%H:%M}\n"
                f"[hyprsunset] Sunset:  {sunset:%H:%M}\n"
                f"[hyprsunset] Morning transition: "
                f"{morning_start:%H:%M} -> {morning_end:%H:%M}\n"
                f"[hyprsunset] Evening transition: "
                f"{evening_start:%H:%M} -> {evening_end:%H:%M}",
                flush=True,
            )
            logged_day = now.date()

        if now < morning_start:
            controller.temperature(night_temperature)

        elif now < morning_end:
            progress = transition_progress(now, morning_start, morning_end)
            temperature = round(
                interpolate(
                    night_temperature,
                    day_temperature,
                    progress,
                )
                / 25
            ) * 25
            controller.temperature(temperature)

        elif now < evening_start:
            controller.identity()

        elif now < evening_end:
            progress = transition_progress(now, evening_start, evening_end)
            temperature = round(
                interpolate(
                    day_temperature,
                    night_temperature,
                    progress,
                )
                / 25
            ) * 25
            controller.temperature(temperature)

        else:
            controller.temperature(night_temperature)

        time.sleep(update_interval)


if __name__ == "__main__":
    main()
