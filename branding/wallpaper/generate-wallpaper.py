#!/usr/bin/env python3
"""
AeroOS Wallpaper Generator
Генерирует стильные темные обои в стиле Fluent Bloom / Aero Flow
"""

import math
import os

def generate_ppm(path, width=1920, height=1080):
    print(f"Генерация обоев {width}x{height} -> {path}...")
    with open(path, "wb") as f:
        f.write(f"P6\n{width} {height}\n255\n".encode())
        for y in range(height):
            row = bytearray()
            ny = y / height
            for x in range(width):
                nx = x / width
                # Центр свечения
                cx = nx - 0.5
                cy = ny - 0.45
                dist = math.sqrt(cx * cx + cy * cy)
                
                # Волны Fluent Bloom
                angle = math.atan2(cy, cx)
                wave = math.sin(dist * 12.0 - angle * 3.0) * 0.15
                dist += wave

                # Цветовая палитра: глубокий ночной индиго (#0f141c) -> лазурный (#0078d4) -> неоновый циан (#00d2ff)
                glow = max(0.0, 1.0 - dist * 1.6)
                glow = glow ** 2.2

                r = int(min(255, 12 + glow * 40 + math.sin(nx * 3.14) * 8))
                g = int(min(255, 18 + glow * 130 + math.cos(ny * 3.14) * 12))
                b = int(min(255, 28 + glow * 225 + 25))
                row.extend([r, g, b])
            f.write(row)
    print("Готово!")

if __name__ == "__main__":
    out_dir = os.path.dirname(os.path.abspath(__file__))
    out_file = os.path.join(out_dir, "1920x1080.ppm")
    generate_ppm(out_file, 1920, 1080)
    print(f"Файл сохранен: {out_file}")
