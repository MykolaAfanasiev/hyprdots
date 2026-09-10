# Конфигурация Mouseless

[English version](README_mouseless.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Keyboard-pointer mappings и системные uinput/udev файлы.

## Файлы

- `99-mouseless.rules`
- `config.yaml`
- `uinput.conf`

## Keyboard layer

Сейчас `Q` используется как `mod-layer`. При удержании `H/J/K/L` двигают указатель, `F/D/S` соответствуют left/right/middle button, `P/N` прокручивают вертикально, а `Left Shift`/`Left Alt` меняют скорость.

Installer настраивает `uinput`, группы и user service. После изменения групп может понадобиться новый login/reboot.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
