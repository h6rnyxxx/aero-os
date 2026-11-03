# Kickstart-файл LiveCD сборки AeroOS (для загрузки с флешки и установки)
%include aero-core.ks

# Настройки Live-образа
part / --size=10240 --fstype=ext4

%packages
# Установщик системы и LiveCD утилиты
calamares
calamares-libs
livecd-tools
memtest86+
%end

%post
echo "=== Настройка Live-сессии AeroOS ==="

# Создание беспарольного liveuser
useradd -m -c "AeroOS Live User" -G wheel liveuser
passwd -d liveuser > /dev/null

# Автологин в графическую сессию SDDM для liveuser
mkdir -p /etc/sddm.conf.d/
cat << 'EOF' > /etc/sddm.conf.d/10-autologin.conf
[Autologin]
User=liveuser
Session=plasmawayland
Relogin=false
EOF

# Иконка установщика на рабочем столе
mkdir -p /home/liveuser/Desktop
cat << 'EOF' > /home/liveuser/Desktop/install-aeroos.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Установить AeroOS на диск
Comment=Запустить графический установщик AeroOS
Exec=calamares
Icon=system-software-install
Terminal=false
StartupNotify=true
Categories=System;
EOF
chmod +x /home/liveuser/Desktop/install-aeroos.desktop
chown -R liveuser:liveuser /home/liveuser/Desktop

echo "LiveCD Post-Install завершен!"
%end
