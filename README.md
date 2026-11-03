# 🪟 AeroOS — Персональная легковесная ОС на базе Fedora

> **Слоган:** *«Знакомый комфорт Windows. Скорость, легкость и независимость Linux.»*  
> **База:** Fedora 40/41 (Minimal RPM, DNF5, Btrfs, Wayland, PipeWire)  
> **Оболочка:** KDE Plasma 6 Fluent Shell (акриловое размытие, скругления 8px, центрированная панель, Snap Layouts)  
> **Целевое железо:** 2–4 ГБ ОЗУ, 2-ядерные процессоры, SSD (загрузка < 12 сек, холодный старт < 600 МБ RAM)

---

## ⚡ Быстрый старт: Как собрать свой ISO прямо сейчас

### Вариант А: Из Windows (через Docker Desktop)
1. Убедитесь, что запущен **Docker Desktop**.
2. Откройте терминал PowerShell в этой папке:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\build\build-in-docker.ps1
   ```
3. Готовый загрузочный образ появится в папке `output\AeroOS-1.0-x86_64.iso`.

### Вариант Б: В среде Linux (Fedora / Ubuntu / VM)
```bash
sudo bash build/build-iso.sh
```

---

## 📂 Структура проекта

```
C:\Users\h6rnyx\Desktop\моя ОС\
├── README.md                          # Главный файл проекта и быстрый старт
├── build/
│   ├── build-iso.sh                   # Скрипт сборки через livemedia-creator (Linux)
│   ├── Containerfile                  # Docker-контейнер для сборки ISO из любой ОС
│   ├── build-in-docker.ps1            # Сборка одной командой из Windows PowerShell
│   └── build-in-wsl.sh                # Сборщик через подсистему WSL2
├── kickstart/
│   ├── aero-core.ks                   # Базовый кикстарт Fedora (пакеты, zRAM, Btrfs, службы)
│   └── aero-live.ks                   # LiveCD кикстарт с установщиком Calamares
├── configs/
│   ├── plasma/                        # Интерфейс в стиле Windows 11
│   │   ├── plasma-org.kde.plasma.desktop-appletsrc # Центрированная плавающая панель
│   │   ├── kwinrc                     # Блюр, скругление 8px, KWin тайлинг (Meta+T)
│   │   ├── kdeglobals                 # Палитра Fluent Dark, шрифт Inter, двойной клик
│   │   ├── dolphinrc                  # Проводник с вкладками и минимальным меню
│   │   └── kscreenlockerrc            # Экран блокировки
│   ├── system/                        # Системные оптимизации для 2-4 ГБ ОЗУ
│   │   ├── 90-aero-minimal.preset     # Отключение Baloo, Tracker, ABRT, PackageKit
│   │   ├── 99-aero-memory.conf        # Твики ядра: swappiness=160, dirty_ratio=10
│   │   ├── zram-generator.conf        # zRAM 150% ОЗУ со сжатием zstd
│   │   ├── nftables.conf              # Легковесный файрвол (экономит 60 МБ ОЗУ)
│   │   └── 10-oomd-permissive.conf    # Защита от зависаний системы при пике памяти
│   └── sddm/
│       └── sddm.conf                  # Вход в систему с поддержкой Wayland
├── compatibility/
│   ├── wine/
│   │   ├── aero-wine-launcher.sh      # Интеллектуальный запуск .exe (Vulkan/OpenGL fallback)
│   │   ├── aero-wine.desktop          # Ассоциация .exe и .msi файлов
│   │   └── default-prefix-setup.sh    # Подготовка идеального чистого Wine-префикса
│   ├── winapps/
│   │   ├── winapps.conf               # Конфиг для запуска Office 365 / Adobe через KVM
│   │   └── setup-winapps.sh           # Скрипт развертывания FreeRDP RAIL
│   └── bottles/
│       └── aero-gaming.yml            # Готовый профиль для запуска игр с Proton-GE
├── apps/
│   └── aero-welcome/                  # Центр приветствия при первом старте
│       ├── aero-welcome.py            # Легковесный GUI визард на Python
│       └── aero-welcome.desktop       # Системный автозапуск
├── branding/
│   ├── info/
│   │   └── os-release                 # Идентификация системы как AeroOS 1.0
│   └── wallpaper/
│       └── generate-wallpaper.py      # Генератор обоев в стиле Fluent Bloom
└── docs/
    ├── ARCHITECTURE.md                # Детальное инженерное описание архитектуры
    ├── BUILD_GUIDE.md                 # Пошаговая инструкция по сборке, установке и тестам
    └── CUSTOMIZATION_GUIDE.md         # Руководство по изменению тем, обоев и драйверов
```

---

## 🎯 Архитектурные особенности

### 1. Как решена проблема «Windows 11 на слабом железе»?
* **Легковесный композитор:** Вместо тяжелых оболочек используется **KDE Plasma 6 (Wayland)** с аппаратным шейдером размытия KWin Blur.
* **Вырезаны пожиратели ОЗУ:** Полностью удалены демоны индексации диска `Baloo` и `Tracker3`, служба отчетов об ошибках `ABRT`, фоновый демон `PackageKit`.
* **zRAM со сжатием zstd:** 2 ГБ физической памяти превращаются в ~4–5 ГБ доступной памяти для приложений без задержек медленного дискового swap.
* **Файловая система Btrfs + Snapper:** Автоматические снимки системы перед каждым обновлением без оверхеда памяти, присущего `rpm-ostree`.

### 2. Запуск Windows-программ
* **.exe и .msi из коробки:** Двойной клик запускает `aero-wine-launcher`. Он проверяет видеокарту:
  * Если GPU поддерживает Vulkan — включает **DXVK / VKD3D**.
  * Если это старый ноутбук (Intel HD 2000/3000/4000) — автоматически переключает на **WineD3D (OpenGL)**, спасая от падения приложения.
* **Изолированный софт:** Предустановлен **Bottles** для игр и программ с особыми библиотеками.
* **Тяжелые пакеты (MS Office 365, Adobe CC):** Подсистема **WinApps** (KVM/QEMU) запускает гостевой Windows headless и выводит отдельные окна приложений прямо на рабочий стол через протокол RDP/RAIL.

---

## 📖 Документация
* Подробнее об архитектуре: [`docs/ARCHITECTURE.md`](file:///C:/Users/h6rnyx/Desktop/моя%20ОС/docs/ARCHITECTURE.md)
* Инструкция по сборке и установке: [`docs/BUILD_GUIDE.md`](file:///C:/Users/h6rnyx/Desktop/моя%20ОС/docs/BUILD_GUIDE.md)
* Кастомизация и драйверы: [`docs/CUSTOMIZATION_GUIDE.md`](file:///C:/Users/h6rnyx/Desktop/моя%20ОС/docs/CUSTOMIZATION_GUIDE.md)
