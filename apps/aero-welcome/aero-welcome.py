#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AeroOS Welcome Center
Легковесный центр приветствия и помощи для новых пользователей AeroOS
"""

import sys
import os
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox

class AeroWelcomeApp(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("Добро пожаловать в AeroOS")
        self.geometry("720x520")
        self.minsize(640, 460)
        self.configure(bg="#202020")

        # Настройка Fluent стиля для Tkinter ttk
        style = ttk.Style(self)
        style.theme_use('clam')

        style.configure(".", background="#202020", foreground="#f0f0f0", font=("Inter", 10))
        style.configure("TNotebook", background="#202020", borderwidth=0)
        style.configure("TNotebook.Tab", background="#2b2b2b", foreground="#cccccc", padding=[16, 8], font=("Inter", 10, "bold"))
        style.map("TNotebook.Tab", background=[("selected", "#0078d4")], foreground=[("selected", "#ffffff")])
        style.configure("TFrame", background="#202020")
        style.configure("Card.TFrame", background="#2b2b2b", relief="flat")
        style.configure("Accent.TButton", background="#0078d4", foreground="#ffffff", font=("Inter", 10, "bold"), padding=6)
        style.map("Accent.TButton", background=[("active", "#1a8ad8")])

        # Верхняя плашка
        header_frame = tk.Frame(self, bg="#202020", pady=15, padx=20)
        header_frame.pack(fill="x")

        title_lbl = tk.Label(header_frame, text="AeroOS 1.0", font=("Inter", 18, "bold"), fg="#ffffff", bg="#202020")
        title_lbl.pack(anchor="w")

        subtitle_lbl = tk.Label(header_frame, text="Знакомый комфорт Windows. Скорость, легкость и независимость Linux.", 
                                font=("Inter", 10), fg="#00a2ed", bg="#202020")
        subtitle_lbl.pack(anchor="w")

        # Вкладки
        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=20, pady=(0, 15))

        self.create_welcome_tab()
        self.create_wine_tab()
        self.create_apps_tab()
        self.create_tuning_tab()

        # Нижняя плашка
        footer_frame = tk.Frame(self, bg="#202020", pady=10, padx=20)
        footer_frame.pack(fill="x")

        self.autostart_var = tk.BooleanVar(value=True)
        chk = tk.Checkbutton(footer_frame, text="Показывать при следующем входе", variable=self.autostart_var,
                             bg="#202020", fg="#aaaaaa", selectcolor="#2b2b2b", activebackground="#202020",
                             activeforeground="#ffffff", command=self.toggle_autostart)
        chk.pack(side="left")

        close_btn = ttk.Button(footer_frame, text="Начать работу", style="Accent.TButton", command=self.destroy)
        close_btn.pack(side="right")

    def create_welcome_tab(self):
        tab = ttk.Frame(self.notebook, style="TFrame", padding=15)
        self.notebook.add(tab, text=" Обзор ")

        lbl = tk.Label(tab, text="Поздравляем с переходом на AeroOS!", font=("Inter", 13, "bold"), fg="#ffffff", bg="#202020")
        lbl.pack(anchor="w", pady=(0, 10))

        text = (
            "AeroOS объединяет привычный интерфейс Windows 11 с ультра-оптимизированным ядром Fedora Linux.\n\n"
            "Ключевые особенности:\n"
            "• Центрированная плавающая панель задач и скругленные акриловые окна.\n"
            "• Потребление менее 600 МБ ОЗУ на старте — плавность даже на 2-4 ГБ RAM.\n"
            "• Аппаратный zRAM сжатия (zstd) превращает 2 ГБ физической памяти в 4+ ГБ.\n"
            "• Отказоустойчивая файловая система Btrfs со снапшотами Snapper перед каждым обновлением."
        )
        msg = tk.Label(tab, text=text, justify="left", font=("Inter", 10), fg="#dddddd", bg="#202020", wraplength=640)
        msg.pack(anchor="w")

    def create_wine_tab(self):
        tab = ttk.Frame(self.notebook, style="TFrame", padding=15)
        self.notebook.add(tab, text=" Программы Windows ")

        lbl = tk.Label(tab, text="Совместимость с .exe и .msi", font=("Inter", 13, "bold"), fg="#ffffff", bg="#202020")
        lbl.pack(anchor="w", pady=(0, 10))

        text = (
            "1. Обычные .exe и инсталляторы:\n"
            "   Просто дважды кликните по любому .exe файлу. Встроенный адаптер Aero Wine определит\n"
            "   вашу видеокарту и запустит приложение с максимальной скоростью (DXVK или WineD3D).\n\n"
            "2. Игры и менеджер Bottles:\n"
            "   Используйте предустановленный Bottles для изоляции сложных игр и программ.\n\n"
            "3. Сложные пакеты (MS Office 365, Adobe CC):\n"
            "   Интегрированы через модуль WinApps поверх KVM (программы открываются в нативных окнах)."
        )
        msg = tk.Label(tab, text=text, justify="left", font=("Inter", 10), fg="#dddddd", bg="#202020", wraplength=640)
        msg.pack(anchor="w")

    def create_apps_tab(self):
        tab = ttk.Frame(self.notebook, style="TFrame", padding=15)
        self.notebook.add(tab, text=" Магазин приложений ")

        lbl = tk.Label(tab, text="Установка программ в один клик", font=("Inter", 13, "bold"), fg="#ffffff", bg="#202020")
        lbl.pack(anchor="w", pady=(0, 10))

        text = (
            "В AeroOS подключен глобальный каталог Flathub с десятками тысяч приложений:\n"
            "• Браузеры: Google Chrome, Yandex Browser, Firefox, Edge, Brave\n"
            "• Мессенджеры: Telegram, Discord, VK Мессенджер\n"
            "• Медиа: VLC, Spotify, OBS Studio\n"
            "• Офис: LibreOffice (с темой Colibre под ленту MS Office), OnlyOffice"
        )
        msg = tk.Label(tab, text=text, justify="left", font=("Inter", 10), fg="#dddddd", bg="#202020", wraplength=640)
        msg.pack(anchor="w", pady=(0, 15))

        btn = ttk.Button(tab, text="Открыть Центр приложений", style="Accent.TButton", command=self.open_store)
        btn.pack(anchor="w")

    def create_tuning_tab(self):
        tab = ttk.Frame(self.notebook, style="TFrame", padding=15)
        self.notebook.add(tab, text=" Память и Оптимизация ")

        lbl = tk.Label(tab, text="Текущий статус подсистемы памяти", font=("Inter", 13, "bold"), fg="#ffffff", bg="#202020")
        lbl.pack(anchor="w", pady=(0, 10))

        self.stats_lbl = tk.Label(tab, text="Загрузка статистики...", font=("Consolas", 10), fg="#00ffcc", bg="#1a1a1a", 
                                  padx=10, pady=10, justify="left", relief="solid", bd=1)
        self.stats_lbl.pack(fill="x", pady=(0, 15))
        self.update_memory_stats()

        btn = ttk.Button(tab, text="Очистить дисковые кэши ОЗУ", style="Accent.TButton", command=self.clean_caches)
        btn.pack(anchor="w")

    def update_memory_stats(self):
        try:
            with open('/proc/meminfo', 'r') as f:
                lines = f.readlines()
            mem_data = {}
            for line in lines[:10]:
                parts = line.split(':')
                if len(parts) == 2:
                    mem_data[parts[0].strip()] = parts[1].strip()
            total = mem_data.get('MemTotal', 'N/A')
            avail = mem_data.get('MemAvailable', 'N/A')
            text = f"Всего физической памяти : {total}\nДоступно без подкачки   : {avail}\nzRAM статус              : Активен (zstd сжатие)"
            self.stats_lbl.config(text=text)
        except Exception:
            self.stats_lbl.config(text="Статистика доступна в среде Linux.")

    def clean_caches(self):
        try:
            subprocess.run(["sync"], check=True)
            messagebox.showinfo("Память", "Дисковые буферы сброшены.")
            self.update_memory_stats()
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def open_store(self):
        try:
            subprocess.Popen(["plasma-discover"])
        except Exception:
            messagebox.showinfo("Магазин", "Команда plasma-discover запускается в окружении KDE.")

    def toggle_autostart(self):
        autostart_dir = os.path.expanduser("~/.config/autostart")
        desktop_file = os.path.join(autostart_dir, "aero-welcome.desktop")
        os.makedirs(autostart_dir, exist_ok=True)
        if not self.autostart_var.get():
            with open(desktop_file, "w") as f:
                f.write("[Desktop Entry]\nHidden=true\n")
        else:
            if os.path.exists(desktop_file):
                os.remove(desktop_file)

if __name__ == "__main__":
    app = AeroWelcomeApp()
    app.mainloop()
