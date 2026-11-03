# Kickstart-файл базового дистрибутива AeroOS (на базе Fedora 40/41 x86_64)
# Предназначен для сборки через livemedia-creator или lorax

version=F40
text
lang ru_RU.UTF-8
keyboard ru,us --vckeymap=ru --xlayouts='ru,us' --switch='grp:alt_shift_toggle'
timezone Europe/Moscow --utc
selinux --enforcing
firewall --enabled

# Репозитории пакетов
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=x86_64"
repo --name=updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=x86_64"
repo --name=rpmfusion-free --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-40&arch=x86_64"
repo --name=rpmfusion-free-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-F40&arch=x86_64"
repo --name=rpmfusion-nonfree --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-40&arch=x86_64"
repo --name=rpmfusion-nonfree-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-F40&arch=x86_64"

# Системные пользователи
rootpw --lock
user --name=aero --groups=wheel --plaintext --password=aero

# Разметка файловой системы Btrfs со сжатием zstd
zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=512
part /boot --fstype=ext4 --size=1024
part btrfs.01 --size=20000 --grow --fstype=btrfs
btrfs none --label=aeroos btrfs.01
btrfs / --subvol --name=root btrfs.01 --fsoptions="compress=zstd:1,noatime"
btrfs /home --subvol --name=home btrfs.01 --fsoptions="compress=zstd:1,noatime"

# Набор пакетов: строгий минимализм и легкость
%packages --excludedocs
# Базовое ядро и микрокод процессоров
kernel
kernel-modules
kernel-modules-extra
linux-firmware
microcode_ctl

# Графический сервер Wayland и минимальный KDE Plasma 6
plasma-desktop
plasma-workspace-wayland
kwin-wayland
plasma-nm
plasma-pa
pipewire
wireplumber
pipewire-pulseaudio
pipewire-alsa
sddm
sddm-kcm

# Базовый легкий софт пользователя
dolphin
konsole
kwrite
fsearch
ark
gwenview

# Шрифты (чистые аналоги Windows 11)
google-inter-fonts
google-noto-sans-fonts
google-noto-color-emoji-fonts
liberation-sans-fonts
liberation-serif-fonts
liberation-mono-fonts

# Подсистема памяти и надежности
zram-generator
snapper
grub-btrfs
btrfs-progs
nftables
curl
git
fastfetch

# Совместимость с Windows (.exe / .msi)
wine-staging
dxvk-native
vkd3d-proton
winetricks
cabextract
p7zip
p7zip-plugins

# Менеджер пакетов Flatpak для приложений
flatpak

# Исключение тяжелых демонов, индексаторов и ненужных утилит (ЭКОНОМИЯ ОЗУ)
-baloo*
-kf6-baloo*
-tracker*
-tracker3*
-PackageKit*
-PackageKit-command-not-found
-abrt*
-sssd*
-ModemManager
-geoclue2
-cups
-firewalld
-kmail
-kaddressbook
-korganizer
-akregator
-kmahjongg
-kmines
-ksudoku
-dragonplayer
-elisa-player
%end

# Пост-инсталляционный скрипт настройки системы
%post
exec < /dev/console > /dev/console
set -x

echo "=== Настройка оптимизаций и внешнего вида AeroOS ==="

# 1. Отключение и маскирование тяжелых служб
systemctl disable ModemManager.service 2>/dev/null || true
systemctl mask NetworkManager-wait-online.service 2>/dev/null || true
systemctl mask dnf-makecache.timer 2>/dev/null || true

# 2. Включение сокетной активации и ключевых служб
systemctl enable sddm.service
systemctl enable systemd-oomd.service

# 3. Настройка прав SELinux для Wine (низкие адреса памяти)
setsebool -P mmap_low_allowed 1 2>/dev/null || true
setsebool -P wine_mmap_zero_ignore 1 2>/dev/null || true

# 4. Подключение репозитория Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 5. Настройка zRAM через генератор (150% ОЗУ, zstd)
cat << 'EOF' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram * 1.5, 6144)
compression-algorithm = zstd
EOF

# 6. Тюнинг ядра для низкой нагрузки на память
cat << 'EOF' > /etc/sysctl.d/99-aero-memory.conf
vm.swappiness = 160
vm.page-cluster = 0
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
EOF

# 7. Замена тяжелого firewalld на легкий nftables
cat << 'EOF' > /etc/sysconfig/nftables.conf
flush ruleset
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif "lo" accept
        ct state established,related accept
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
systemctl enable nftables.service

# 8. Создание глобального профиля пользователя в /etc/skel
mkdir -p /etc/skel/.config/
mkdir -p /etc/skel/Desktop
mkdir -p /etc/skel/Downloads
mkdir -p /etc/skel/Documents

echo "AeroOS Core Post-Install завершен успешно!"
%end
