<#
.SYNOPSIS
    Сборка ISO-образа AeroOS прямо из Windows через Docker Desktop.
.DESCRIPTION
    Скрипт собирает специализированный Fedora 40 контейнер с lorax и livemedia-creator,
    монтирует текущий проект и собирает загрузочный ISO файл в папку 'output'.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$OutputDir = Join-Path $ProjectRoot "output"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       AeroOS: Сборка ISO через Docker Desktop (Windows)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Проверка работы Docker
try {
    docker info | Out-Null
} catch {
    Write-Error "Docker Desktop не запущен или не установлен! Пожалуйста, запустите Docker Desktop и повторите попытку."
    exit 1
}

# 2. Создание каталога вывода
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# 3. Сборка сборочного образа
Write-Host "[*] Сборка сборочного контейнера aero-builder:f40..." -ForegroundColor Yellow
docker build -t aero-builder:f40 -f (Join-Path $ScriptDir "Containerfile") $ScriptDir

# 4. Запуск сборщика в привилегированном контейнере
# (Привилегированный режим необходим для создания loop-устройств монтирования дисков и squashfs)
Write-Host "[*] Запуск компиляции ISO образа в контейнере..." -ForegroundColor Yellow
Write-Host "[*] Это займет некоторое время (скачивание пакетов и создание squashfs)..." -ForegroundColor Gray

docker run --rm --privileged `
    -v "${ProjectRoot}:/workspace" `
    -w /workspace `
    aero-builder:f40

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "[+] Сборка завершена! Проверьте папку: $OutputDir" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
