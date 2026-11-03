#!/usr/bin/env bash
# ==============================================================================
# Скрипт автоматического развертывания подсистемы WinApps (QEMU/KVM + FreeRDP)
# ==============================================================================
set -e

echo "=== Установка подсистемы бесшовных приложений Windows (WinApps) ==="

# 1. Установка пакетов виртуализации и FreeRDP
sudo dnf install -y qemu-kvm libvirt virt-install freerdp virt-viewer

# 2. Включение службы виртуализации
sudo systemctl enable --now libvirtd
sudo usermod -a -G libvirt $(whoami)

# 3. Скачивание и установка интегратора WinApps
WINAPPS_DIR="$HOME/.local/share/winapps"
mkdir -p "$WINAPPS_DIR"

if [ ! -d "$WINAPPS_DIR/repo" ]; then
    git clone --depth=1 https://github.com/winapps-org/winapps.git "$WINAPPS_DIR/repo"
fi

# Копирование преднастроенного конфига
mkdir -p "$HOME/.config/winapps"
cp "$(dirname "$0")/winapps.conf" "$HOME/.config/winapps/winapps.conf"

echo "=== WinApps установлен! ==="
echo "Для завершения настройки создайте минимальную VM с Windows 10/11 в virt-manager"
echo "и включите в ней RDP (Удаленный рабочий стол)."
