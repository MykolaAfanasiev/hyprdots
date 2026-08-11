# Конфигурация SwayNC

Минималистичная и модульная конфигурация SwayNC для Hyprland.

Конфигурация отвечает за всплывающие уведомления, центр уведомлений, режим Do Not Disturb, оформление Catppuccin Mocha и управление с клавиатуры через Hyprland.

[English version](README_SwayNC.md) · [Назад к hyprdots](../../)

## Возможности

- всплывающие уведомления
- Notification Control Center
- режим Do Not Disturb
- группировка уведомлений
- относительное отображение времени
- изображения в уведомлениях, если они доступны
- отдельные timeout для low, normal и critical уведомлений
- цветовая тема Catppuccin Mocha
- прозрачный Control Center и карточки уведомлений
- отдельная прозрачность для floating notifications
- модульная структура CSS-тем
- отдельный скрипт запуска
- единый control-скрипт для открытия панели, DND и reload
- интеграция с биндами и `config` submap Hyprland
- независимые от расположения репозитория пути через модуль путей Hyprland
- JSON Schema для проверки конфигурации и автодополнения в редакторе

## Структура

```text
swaync/
├── config.json
├── style.css
├── launch.sh
├── scripts/
│   └── control.sh
└── themes/
    ├── current.css
    └── catppuccin-mocha.css
```

### Файлы

| Файл | Назначение |
|---|---|
| `config.json` | Основные настройки поведения SwayNC и widgets |
| `style.css` | Основной layout и оформление уведомлений и Control Center |
| `launch.sh` | Запуск SwayNC с конфигурацией из репозитория |
| `scripts/control.sh` | Управление панелью, DND и reload конфигурации |
| `themes/current.css` | Подключение текущей цветовой палитры |
| `themes/catppuccin-mocha.css` | Палитра Catppuccin Mocha и семантические переменные SwayNC |

## Конфигурация

В `config.json` используется системная JSON Schema SwayNC:

```json
{
  "$schema": "/etc/xdg/swaync/configSchema.json"
}
```

Сама schema не является частью dotfiles. Она устанавливается вместе с SwayNC и может использоваться редактором для проверки параметров и автодополнения.

Текущее расположение уведомлений:

```text
По горизонтали: справа
По вертикали:   сверху
```

Ширина Control Center и окна всплывающих уведомлений сейчас установлена в `500` пикселей.

### Timeout

```text
Low        5 секунд
Normal    10 секунд
Critical   без автоматического закрытия
```

Critical notification остаётся на экране до закрытия или выполнения действия.

## Control Center

Сейчас Control Center содержит три widgets:

```text
Notifications + Clear All
Do Not Disturb
Список уведомлений
```

Они задаются через:

```json
"widgets": [
  "title",
  "dnd",
  "notifications"
]
```

Список уведомлений растягивается на оставшееся место панели.

## Скрипт запуска

SwayNC запускается через `launch.sh`, поэтому конфигурация не зависит от стандартного расположения `~/.config/swaync`.

```bash
#!/usr/bin/env bash

SWAYNC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec swaync \
    -c "$SWAYNC_DIR/config.json" \
    -s "$SWAYNC_DIR/style.css"
```

Скрипт сам определяет свою директорию, поэтому расположение репозитория не нужно прописывать вручную.

## Control-скрипт

Все runtime-действия собраны в:

```text
scripts/control.sh
```

Поддерживаемые действия:

```bash
./scripts/control.sh toggle
./scripts/control.sh dnd
./scripts/control.sh reload
```

### Открытие Control Center

```bash
swaync-client -t
```

Открывает или закрывает панель SwayNC.

### Do Not Disturb

```bash
swaync-client -d
```

Переключает режим Do Not Disturb.

### Reload

```bash
swaync-client -R
swaync-client -rs
```

Перезагружает и `config.json`, и `style.css` без полного перезапуска SwayNC.

`control.sh` также является подходящим местом для feedback-уведомлений Hyprland, например:

```text
Do Not Disturb: ON
Do Not Disturb: OFF
SwayNC reloaded
```

Так логика подтверждения действий не размазывается по Lua-файлам Hyprland.

## Интеграция с Hyprland

Пути SwayNC централизованы в модуле путей Hyprland:

```lua
M.swaync = {
    root = project_root .. "configs/swaync/",
    launch = project_root .. "configs/swaync/launch.sh",
    control = project_root .. "configs/swaync/scripts/control.sh",
}
```

При запуске Hyprland SwayNC стартует через:

```lua
hl.exec_cmd(paths.swaync.launch)
```

### Глобальный bind

```text
ALT + N → открыть / закрыть Control Center
```

Bind вызывает общий control-скрипт:

```lua
hl.bind(
    "ALT + N",
    hl.dsp.exec_cmd(paths.swaync.control .. " toggle")
)
```

## Hyprland Config Submap

Управление SwayNC встроено в Hyprland `config` submap.

Навигация:

```text
SUPER + Ctrl + Shift + N
        ↓
      config
        ↓ S
  config_swaync
```

Внутри `config_swaync`:

| Клавиша | Действие |
|---|---|
| `D` | Переключить Do Not Disturb |
| `R` | Перезагрузить config и CSS SwayNC |
| `Esc` | Вернуться в основной `config` submap |
| `Shift + Esc` | Вернуться к глобальным биндам |

## Стили

Оформление отделено от цветовой палитры:

```text
style.css
    ↓
themes/current.css
    ↓
themes/catppuccin-mocha.css
```

`style.css` отвечает за layout и внешний вид widgets, а файл темы содержит цвета и общие семантические переменные.

Используемый шрифт:

```text
JetBrainsMono Nerd Font
```

Основные особенности оформления:

- цвета Catppuccin Mocha
- скруглённые карточки уведомлений
- прозрачные floating notifications
- прозрачный фон Control Center
- лёгкие границы карточек
- без теней у уведомлений
- приглушённый вторичный текст
- mauve для активных элементов
- red для critical notifications и hover кнопки закрытия

## Прозрачность

Прозрачность Control Center и уведомлений задаётся независимо в теме.

Текущие значения:

```css
--cc-bg: rgba(30, 30, 46, 0.88);

--noti-bg: 49, 50, 68;
--noti-bg-alpha: 0.92;
--floating-noti-bg-alpha: 0.82;
```

Благодаря этому можно независимо менять прозрачность панели, карточек внутри Control Center и всплывающих уведомлений.

Для floating notifications можно использовать отдельное правило:

```css
.floating-notifications
.notification-row
.notification-background
.notification {
    background: rgba(
        var(--noti-bg),
        var(--floating-noti-bg-alpha)
    );
}
```

## Темы

Активная тема выбирается через:

```text
themes/current.css
```

Сейчас подключена:

```css
@import url("catppuccin-mocha.css");
```

Чтобы добавить другую тему, достаточно создать новый файл палитры и изменить только import в `current.css`.

Например:

```css
@import url("gruvbox.css");
```

Основной `style.css` переписывать не потребуется.

## Catppuccin Mocha

Файл темы содержит стандартную палитру Catppuccin Mocha и отдельные семантические переменные для SwayNC.

Пример:

```css
--cc-bg: rgba(30, 30, 46, 0.88);
--noti-bg: 49, 50, 68;
--noti-bg-hover: var(--surface1);
--noti-border-color: var(--surface1);

--text-color: var(--text);
--accent: var(--mauve);
--critical: var(--red);
```

Благодаря семантическим переменным цветовую схему можно заменить, не меняя layout и правила оформления SwayNC.

## Проверка

Отправить тестовое уведомление:

```bash
notify-send "SwayNC" "Test notification"
```

Открыть / закрыть Control Center:

```bash
./scripts/control.sh toggle
```

Переключить DND:

```bash
./scripts/control.sh dnd
```

Перезагрузить конфиг и CSS:

```bash
./scripts/control.sh reload
```

## Зависимости

Для текущей конфигурации нужны:

```text
swaync
hyprland
JetBrainsMono Nerd Font
```

Для ручной проверки уведомлений удобно использовать `notify-send`, который обычно устанавливается пакетом `libnotify`.

## Основные принципы

Конфигурация следует тому же подходу, что Waybar и Rofi:

- отделять поведение от оформления
- хранить палитру отдельно от layout CSS
- не использовать жёстко заданные пути к репозиторию
- собирать runtime-действия в небольших скриптах
- интегрировать управление компонентами в Hyprland submaps
- сохранять управление с клавиатуры
- минимизировать визуальный шум
- делать темы легко заменяемыми
