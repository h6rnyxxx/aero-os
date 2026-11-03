#!/usr/bin/env bash
# ==============================================================================
# AeroOS Сборщик через WSL2 (Ubuntu / Fedora / Debian в Windows)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Сборка AeroOS внутри окружения WSL2 ==="

# Проверка дистрибутива WSL
if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y lorax pykickstart
elif command -v apt-get >/dev/null 2>&1; then
    echo "[*] Обнаружен Ubuntu/Debian WSL. Для сборки Fedora ISO используйте Docker или Fedora WSL."
    echo "    Рекомендуется запустить: powershell.exe -ExecutionPolicy Bypass -File build/build-in-docker.ps1"
    exit 1
fi

sudo bash "$SCRIPT_DIR/build-iso.sh"
