# Конфигурация Rofi

Минималистичная и модульная конфигурация Rofi для Hyprland.

Конфигурация объединяет запуск приложений, переключение между открытыми окнами и историю буфера обмена, сохраняя общий визуальный стиль остальных компонентов рабочего окружения.

[English version](README_Rofi.md) · [Назад к hyprdots](../../)

## Возможности

- объединённый launcher из `drun` и `window`
- короткие префиксы режимов `D` / `W`
- fuzzy-поиск
- иконки приложений
- отображение результатов в две колонки
- цветовая тема Catppuccin Mocha
- отдельный скрипт запуска
- история буфера обмена через `cliphist`
- сохранение текущего clipboard через `wl-clip-persist`
- единый стиль Rofi для launcher и clipboard picker
- интеграция с биндами Hyprland
- независимые от расположения репозитория пути через модуль путей Hyprland

## Структура

```text
rofi/
├── config.rasi
├── theme.rasi
├── launch.sh
├── clipboard.sh
└── themes/
    ├── current.rasi
    └── catppuccin-mocha.rasi
```

### Файлы

| Файл | Назначение |
|---|---|
| `config.rasi` | Основные настройки поведения и режимов Rofi |
| `theme.rasi` | Основной layout и стили элементов |
| `launch.sh` | Запуск основного Rofi launcher |
| `clipboard.sh` | Открытие истории clipboard и восстановление выбранной записи |
| `themes/current.rasi` | Подключение текущей цветовой палитры |
| `themes/catppuccin-mocha.rasi` | Палитра Catppuccin Mocha |

## Launcher

Основной launcher использует режим Rofi `combi` и объединяет:

```text
W → открытые окна
D → установленные приложения
```

Текущая конфигурация:

```rasi
configuration {
    modes: [ combi ];
    combi-modes: [ window, drun ];

    combi-hide-mode-prefix: false;
    combi-display-format: "{mode} {text}";

    window {
        display-name: "W";
    }

    drun {
        display-name: "D";
    }

    show-icons: true;
    matching: "fuzzy";
    sorting-method: "fzf";

    drun-display-format: "{name}";
    window-format: "{c} · {t:20}";

    font: "JetBrainsMono Nerd Font 13";
}

@theme "theme.rasi"
```

Названия приложений остаются компактными, а заголовки окон ограничены 20 символами.

## Скрипт запуска

Rofi запускается через `launch.sh`, поэтому конфигурация не зависит от стандартного расположения `~/.config/rofi`.

```bash
#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec rofi \
    -config "$ROFI_DIR/config.rasi" \
    -show combi
```

Скрипт самостоятельно определяет свою директорию, поэтому его можно запускать из любой рабочей директории.

## История буфера обмена

История clipboard построена по схеме:

```text
wl-clipboard
    ↓
cliphist
    ↓
Rofi
    ↓
wl-copy
```

При старте Hyprland запускаются watchers для текста и изображений:

```lua
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type image --watch cliphist store")
hl.exec_cmd("wl-clip-persist --clipboard regular")
```

`clipboard.sh` показывает сохранённые записи через Rofi:

```bash
#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

selection="$(
    cliphist list |
        rofi \
            -dmenu \
            -display-columns 2 \
            -config "$ROFI_DIR/config.rasi" \
            -theme "$ROFI_DIR/theme.rasi"
)"

[[ -z "$selection" ]] && exit 0

printf '%s\n' "$selection" |
    cliphist decode |
    wl-copy
```

После выбора запись снова становится текущим содержимым Wayland clipboard и может быть вставлена обычным `Ctrl + V`.

## Интеграция с Hyprland

Пути Rofi централизованы в модуле путей Hyprland:

```lua
M.rofi = {
    root = project_root .. "configs/rofi/",
    launch = project_root .. "configs/rofi/launch.sh",
    clipboard = project_root .. "configs/rofi/clipboard.sh",
}
```

Текущие бинды:

| Клавиша | Действие |
|---|---|
| `SUPER + Space` | Открыть Rofi launcher |
| `SUPER + Shift + V` | Открыть историю clipboard |

Бинды используют централизованные пути и не содержат жёстко заданного расположения репозитория.

## Layout

Launcher использует расположенное по центру поле поиска и список результатов в две колонки:

```text
╭────────────────────────────────────────────────────╮
│                       Search                       │
│                                                    │
│  D Firefox                    D Obsidian            │
│  W firefox · ChatGPT          D Kitty               │
│  D Visual Studio Code         W kitty · nvim        │
╰────────────────────────────────────────────────────╯
```

Placeholder `Search` автоматически исчезает после начала ввода текста.

## Стили

Поведение Rofi отделено от оформления:

```text
config.rasi
    ↓
theme.rasi
    ↓
themes/current.rasi
    ↓
themes/catppuccin-mocha.rasi
```

Основное окно использует базовый цвет Catppuccin, а строка поиска и выбранные элементы используют цвета `surface`.

Пример:

```rasi
window {
    background-color: @base;
    border-color: @surface1;
    border-radius: 14px;
}

inputbar {
    background-color: @surface0;
    border-radius: 14px;
}

element selected.normal {
    background-color: @surface0;
    text-color: @text;
}
```

## Темы

Активная палитра выбирается через:

```text
themes/current.rasi
```

Текущая конфигурация:

```rasi
@import "catppuccin-mocha.rasi"
```

Так выбор палитры остаётся независимым от layout и позволяет позже легко добавлять новые темы.

## Шрифт

Используется:

```text
JetBrainsMono Nerd Font
```

Nerd Font рекомендуется для корректного отображения иконок приложений.

## Зависимости

Для текущей конфигурации используются:

```text
rofi
cliphist
wl-clipboard
wl-clip-persist
JetBrainsMono Nerd Font
```

## Основные принципы

- keyboard-first workflow
- один launcher для приложений и окон
- быстрый fuzzy-поиск
- минимум визуального шума
- единый визуальный стиль с Waybar
- переиспользуемые launch-скрипты
- централизованные пути репозитория
- разделение layout и цветовой палитры
- история clipboard без отдельного GUI-приложения
