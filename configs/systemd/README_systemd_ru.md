# systemd user units

[English version](README_systemd.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Управляемые репозиторием user units и drop-ins для desktop services.

## Файлы

- `user/mouseless.service`

## Управляемые units

`mouseless.service` запускает keyboard-pointer daemon. `mpd.service.d/10-hyprdots.conf` добавляет repository-specific user-unit настройки MPD. После Stow installer перезагружает user systemd manager.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
