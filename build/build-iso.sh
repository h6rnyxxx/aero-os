#!/usr/bin/env bash
# ==============================================================================
# AeroOS Automated ISO Builder
# Использует Lorax / livemedia-creator для генерации загрузочного Live-образа
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KICKSTART_FILE="$PROJECT_ROOT/kickstart/aero-live.ks"
OUTPUT_DIR="$PROJECT_ROOT/output"
TMP_DIR="/var/tmp/aero-build-$(date +%s)"
RELEASE_VER="40"
VOLUME_ID="AeroOS-1.0-x86_64"
ISO_NAME="AeroOS-1.0-x86_64.iso"

echo "=========================================================="
echo "          AeroOS 1.0 ISO Build Pipeline                   "
echo "=========================================================="

# 1. Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "[!] Ошибка: Сборка ISO образа требует прав root (sudo)." >&2
    exit 1
fi

# 2. Проверка необходимых утилит
for cmd in livemedia-creator ksflatten sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Утилита '$cmd' не найдена. Устанавливаем зависимости..."
        dnf install -y lorax pykickstart
        break
    fi
done

# 3. Подготовка рабочего пространства
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TMP_DIR"

echo "[*] Валидация и склейка Kickstart-файлов..."
FLATTENED_KS="$TMP_DIR/flattened-aero.ks"
ksflatten -v F40 -c "$KICKSTART_FILE" -o "$FLATTENED_KS"

echo "[*] Подготовка Kickstart завершена успешно."

# 4. Запуск генерации ISO через livemedia-creator
echo "[*] Запуск livemedia-creator (может занять 15-30 минут в зависимости от скорости сети)..."

LOG_FILE="$OUTPUT_DIR/build.log"

livemedia-creator \
    --make-iso \
    --ks="$FLATTENED_KS" \
    --no-virt \
    --iso-only \
    --releasever="$RELEASE_VER" \
    --project="AeroOS Live" \
    --volid="$VOLUME_ID" \
    --resultdir="$OUTPUT_DIR" \
    --tmp="$TMP_DIR" 2>&1 | tee "$LOG_FILE"

# 5. Постобработка и хеширование
FINAL_ISO=$(find "$OUTPUT_DIR" -maxdepth 1 -name "*.iso" | head -n 1)

if [ -f "$FINAL_ISO" ]; then
    mv "$FINAL_ISO" "$OUTPUT_DIR/$ISO_NAME"
    echo "=========================================================="
    echo "[+] Сборка успешно завершена!"
    echo "[+] ISO образ: $OUTPUT_DIR/$ISO_NAME"
    
    echo "[*] Расчет контрольной суммы SHA256..."
    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
    echo "[+] Хэш: $(cat "$ISO_NAME.sha256")"
    echo "=========================================================="
else
    echo "[!] Ошибка: ISO файл не был сгенерирован. Проверьте $LOG_FILE" >&2
    exit 1
fi

# Очистка временных файлов
rm -rf "$TMP_DIR"
