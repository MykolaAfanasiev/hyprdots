# Конфигурация Waybar

Минималистичная и модульная конфигурация Waybar для Hyprland.

Основная идея — чистый внешний вид, управление с клавиатуры и простая
настройка отдельных компонентов.

[English version](README_Waybar.md)  · [Вернутся к hyprdots](../../)

## Возможности

- интеграция с workspace Hyprland
- отображение активного Hyprland submap
- отображение раскладки клавиатуры
- управление звуком через WirePlumber
- system tray
- собственный модуль часов
- компактный и расширенный режим часов
- перезапуск Waybar с клавиатуры
- цветовая тема Catppuccin Mocha
- отдельная система CSS-тем
- собственный `launch.sh`
- интеграция с Hyprland `config` submap

## Структура

```text
waybar/
├── config.jsonc
├── style.css
├── launch.sh
├── scripts/
│   └── clock.sh
└── themes/
    ├── current.css
    └── catppuccin-mocha.css
```

### Файлы

| Файл | Назначение |
|---|---|
| `config.jsonc` | Основная конфигурация Waybar |
| `style.css` | Основные стили и расположение модулей |
| `launch.sh` | Скрипт запуска Waybar |
| `scripts/clock.sh` | Логика собственного модуля часов |
| `themes/current.css` | Подключение текущей темы |
| `themes/catppuccin-mocha.css` | Цветовая палитра Catppuccin Mocha |

## Расположение модулей

Текущая структура панели:

```text
Слева                Центр                  Справа
────────────────────────────────────────────────────────
Workspaces            Submap     Tray  Layout  Volume  Clock
```

## Запуск

Waybar запускается через:

```bash
./launch.sh
```

`launch.sh` автоматически определяет директорию конфигурации и сохраняет
её в переменной окружения:

```bash
WAYBAR_CONFIG_DIR
```

Благодаря этому остальные скрипты Waybar не зависят от абсолютного пути
к репозиторию dotfiles.

## Собственные часы

Стандартный модуль часов Waybar заменён собственным скриптом:

```text
scripts/clock.sh
```

Есть два режима.

Компактный:

```text
14:32
```

Расширенный:

```text
Monday, August 10, 2026 14:32:45
```

Переключение выполняется командой:

```bash
./scripts/clock.sh toggle
```

## Config submap

Управление Waybar встроено в Hyprland `config` submap.

```text
SUPER + Ctrl + Shift + N
        ↓
      config
        ↓ W
  config_waybar
```

Внутри `config_waybar`:

| Клавиша | Действие |
|---|---|
| `1` | Переключить режим часов |
| `R` | Перезапустить Waybar |
| `Esc` | Вернуться в `config` |
| `Shift + Esc` | Вернуться к глобальным биндам |

## Workspaces

Для отображения рабочих столов используется:

```text
hyprland/workspaces
```

Также поддерживаются специальные workspace.

```text
terminal   → 
monitor    → 󰍛
notes      → 󰎚
```

## Звук

Для отображения громкости используется WirePlumber:

```text
wireplumber
```

Пример:

```text
󰕿 100%
```

## Стили

Waybar имеет прозрачный основной фон, а отдельные модули используют
собственные контейнеры.

Размеры отступов в основном задаются через `em`, поэтому интерфейс
масштабируется вместе с размером шрифта.

## Темы

Цветовая палитра отделена от основной логики CSS.

```text
style.css
    ↓
themes/current.css
    ↓
themes/catppuccin-mocha.css
```

Основной `style.css` использует семантические цвета:

```css
@define-color module_bg @surface0;
@define-color module_fg @text;
@define-color module_hover @surface1;

@define-color accent @mauve;
@define-color accent_fg @crust;

@define-color muted @overlay0;
@define-color warning @yellow;
@define-color critical @red;
```

Благодаря этому тему можно менять без переписывания стилей каждого
модуля.

## Шрифт

Для отображения иконок требуется Nerd Font.

Рекомендуемый вариант:

```text
JetBrainsMono Nerd Font
```

## Основные принципы

Конфигурация строится вокруг нескольких принципов:

- минимальный визуальный шум
- отдельные контейнеры для модулей
- управление с клавиатуры
- переиспользуемые скрипты
- отсутствие жёстко заданного пути к репозиторию
- централизованная работа с путями
- возможность быстро менять цветовые темы

