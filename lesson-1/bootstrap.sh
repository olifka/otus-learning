#!/bin/bash
echo -e "\nlsblk on start:\n"
lsblk
# Устанавливаем необходимые пакеты для сборки массива и переноса системы
yum -y install mdadm xfsdump
# Создаём RAID0
yes | mdadm --create /dev/md/raid0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
# Создаём таблицу разделов и ФС на массиве
parted -s -a optimal -- /dev/md/raid0 mkpart primary 1MiB -2048s
mkfs.xfs /dev/md/raid0
# Получаем UUID массива и hdd
RAID_UUID=`blkid -o udev /dev/md/raid0|grep ID_FS_UUID=|awk -F "=" '{print $2}'`
HDD_UUID=`blkid -o udev /dev/sda1|grep ID_FS_UUID=|awk -F "=" '{print $2}'`
echo -e "\nlsblk after RAID creation:\n"
lsblk
# Монтируем массив и переносим на него данные из корня системы
mount /dev/md/raid0 /mnt
xfsdump -J - /dev/sda1 | xfsrestore -J - /mnt
# Монтируем системные папки
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
# Генерируем скрипт для переустановки grub на новый диск и запускаем его в chroot
echo '#!/bin/bash' > /mnt/grub_installer.sh
echo "RAID_UUID=$RAID_UUID" >> /mnt/grub_installer.sh
echo "HDD_UUID=$HDD_UUID" >> /mnt/grub_installer.sh
echo "grub2-mkconfig -o /boot/grub2/grub.cfg" >> /mnt/grub_installer.sh
echo 'cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done' >> /mnt/grub_installer.sh
echo 'sed -i "s/$HDD_UUID/$RAID_UUID/g" /boot/grub2/grub.cfg' >> /mnt/grub_installer.sh
chmod +x /mnt/grub_installer.sh
chroot /mnt ./grub_installer.sh
reboot
