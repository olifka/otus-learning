#!/bin/bash
# Переименовываем VG
vgrename -v VolGroup00 VG00
# Иправляем вхождения старого имени VG на новое
# в файлах /etc/fstab /boot/grub2/grub.cfg
sed -i 's/VolGroup00/VG00/g' /etc/fstab
sed -i 's/VolGroup00/VG00/g' /boot/grub2/grub.cfg
# Генерируем новый initrd командой mkinitrd
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
# Безуспешно пытаемся ребутнуться =)
# Попробовал разные способы - в VirtualBox  один не сработал
init 6
# systemctl reboot
# reboot
# shutdown -r now
