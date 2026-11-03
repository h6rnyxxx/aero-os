@echo off
chcp 65001 > nul
powershell.exe -ExecutionPolicy Bypass -File "%~dp0enable-cloud-builds.ps1"
