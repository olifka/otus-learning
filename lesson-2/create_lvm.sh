#!/bin/bash
# Удаляем ЛВ и ВГ с предыдущего диска, чтобы создать его с правильным именем
lvremove -f /dev/vg_tmp_root/lv_tmp_root
vgremove vg_tmp_root
# Создаём новые ВГ и тома под /var и /home. Том под /var создан с опцией -m1, а ля RAID1
vgcreate VolGroup01 /dev/sdb /dev/sdc
vgcreate VolGroup02 /dev/sdd /dev/sde
yes | lvcreate -n lv_home -L 10G VolGroup01
lvcreate -n lv_var -l +100%FREE -m1 VolGroup02
# Уже ставшая привычной процедура переноса файла на новый диск
mkfs.xfs /dev/VolGroup01/lv_home
mkfs.xfs /dev/VolGroup02/lv_var
mount /dev/VolGroup02/lv_var /mnt
cp -apx /var/* /mnt/.
umount /mnt
mount /dev/VolGroup01/lv_home /mnt
cp -apx /home/* /mnt/.
umount /mnt
# Правка fstab для использования новых разделов
echo "/dev/mapper/VolGroup01-lv_home /home                       xfs     defaults        0 0" >> /etc/fstab 
echo "/dev/mapper/VolGroup02-lv_var /var                       xfs     defaults        0 0" >> /etc/fstab 
# Перемонтирование
mount -a
