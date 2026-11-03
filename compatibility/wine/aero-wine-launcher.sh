#!/usr/bin/env bash
# ==============================================================================
# AeroOS Intelligent Wine Launcher
# Обработчик запуска .exe и .msi файлов с автоопределением железа
# ==============================================================================

set -e

EXE_PATH="$1"
if [ -z "$EXE_PATH" ]; then
    notify-send -i dialog-error "AeroOS Wine" "Не указан исполняемый файл для запуска."
    exit 1
fi

WINE_DIR="$HOME/.local/share/aero-wine"
PREFIX="$WINE_DIR/default"
mkdir -p "$WINE_DIR"

# 1. Проверка и первичная инициализация префикса Wine
if [ ! -d "$PREFIX" ]; then
    notify-send -i wine "AeroOS Wine" "Первый запуск: инициализация системного окружения Windows..."
    export WINEPREFIX="$PREFIX"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    wineboot -i
    # Отключение отслеживания ненужных ассоциаций файлов в реестре Wine
    wine reg add "HKEY_CURRENT_USER\Software\Wine\FileOpenAssociations" /v "Enable" /t REG_DWORD /d 0 /f > /dev/null 2>&1 || true
fi

export WINEPREFIX="$PREFIX"

# 2. Интеллектуальное определение видеокарты и драйвера
# Если GPU поддерживает Vulkan (DXVK), используем нативную трансляцию
# Если старый чипсет (Intel HD 2000/3000/4000) без Vulkan - fallback на WineD3D (OpenGL)
HAS_VULKAN=false
if command -v vulkaninfo >/dev/null 2>&1; then
    if vulkaninfo --summary >/dev/null 2>&1; then
        HAS_VULKAN=true
    fi
fi

if [ "$HAS_VULKAN" = true ]; then
    # Активируем DXVK / VKD3D
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;dxgi,d3d11,d3d10core,d3d9=n,b"
else
    # Fallback на проверенный OpenGL WineD3D (защита от падений старых ноутбуков)
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;dxgi,d3d11,d3d10core,d3d9=b"
fi

# 3. Поддержка Wayland и масштабирования
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # Экспериментальный нативный Wayland драйвер для Wine 9+ (если доступен)
    export WINE_ALLOW_WAYLAND=1
fi

# Отключение всплывающих диалогов краха для лучшего UX
export WINEDEBUG="-all"

EXE_NAME=$(basename "$EXE_PATH")
notify-send -i application-x-ms-dos-executable "AeroOS Wine" "Запуск $EXE_NAME..."

# 4. Непосредственный запуск
exec wine "$EXE_PATH" "${@:2}"
