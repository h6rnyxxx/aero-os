#!/usr/bin/env bash
# Скрипт тонкой настройки чистого префикса Wine в AeroOS
set -e

PREFIX="${1:-$HOME/.local/share/aero-wine/default}"
export WINEPREFIX="$PREFIX"
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

echo "Инициализация префикса: $PREFIX"
wineboot -u

# Установка базовых шрифтов Windows через winetricks
if command -v winetricks >/dev/null 2>&1; then
    echo "Установка системных шрифтов (corefonts)..."
    winetricks -q corefonts || true
fi

# Твики реестра: сглаживание шрифтов Subpixel RGB (ClearType аналог)
wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f
wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "FontSmoothingType" /t REG_DWORD /d 2 /f
wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "FontSmoothingOrientation" /t REG_DWORD /d 1 /f

echo "Префикс успешно оптимизирован!"
