<#
.SYNOPSIS
    Активация автоматической облачной сборки ISO (GitHub Actions)
#>

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    Активация автоматической сборки ISO на серверах GitHub " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для того чтобы GitHub разрешил скрипту запускать сборку ISO в облаке," -ForegroundColor Yellow
Write-Host "нужно дать однократное разрешение (права 'workflow')." -ForegroundColor Yellow
Write-Host ""
Write-Host "Сейчас откроется браузер GitHub. Нажмите зеленую кнопку 'Authorize'." -ForegroundColor Green
Write-Host ""

# Обновляем права GitHub CLI
gh auth refresh -s workflow

# После авторизации переносим workflow файл и пушим в репозиторий
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
Move-Item -Force "ci\build-iso.yml" ".github\workflows\build-iso.yml"
Remove-Item -Recurse -Force "ci" -ErrorAction SilentlyContinue

git add -A
git commit -m "Activate automated GitHub Actions ISO builder"
git push origin main

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "[+] Автосборка успешно включена!" -ForegroundColor Green
Write-Host "[+] Теперь каждое обновление проекта автоматически компилирует свежий ISO!" -ForegroundColor Green
Write-Host "[+] Ссылка на репозиторий: https://github.com/h6rnyxxx/aero-os/actions" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green
Pause
