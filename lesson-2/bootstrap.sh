#!/bin/bash
# Устанавливаем необходимые для работы с lvm и xfs пакеты
yum -y install lvm2 xfsdump
# Создаём группу томов и LV для временного хранения корня
pvcreate /dev/sdb
vgcreate vg_tmp_root /dev/sdb
lvcreate -n lv_tmp_root -l +100%FREE /dev/vg_tmp_root
mkfs.xfs /dev/vg_tmp_root/lv_tmp_root
# Переносим систему на новый раздел
mount /dev/vg_tmp_root/lv_tmp_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
# Генерим и запускаем в чрут скрипт для обновления конфигурации граб и образов инитрд
echo '#!/bin/bash' > /mnt/grub_installer.sh
echo "grub2-mkconfig -o /boot/grub2/grub.cfg" >> /mnt/grub_installer.sh
echo 'cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done' >> /mnt/grub_installer.sh
echo 'sed -i "s/lv=VolGroup00\/LogVol00/lv=vg_tmp_root\/lv_tmp_root/g" /boot/grub2/grub.cfg' >> /mnt/grub_installer.sh
chmod +x /mnt/grub_installer.sh
chroot /mnt ./grub_installer.sh
# Подправляем тот же скрипт для повторного использования при следующей загрузке
echo '#!/bin/bash' > /mnt/grub_installer.sh
echo "grub2-mkconfig -o /boot/grub2/grub.cfg" >> /mnt/grub_installer.sh
echo 'cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done' >> /mnt/grub_installer.sh
echo 'sed -i "s/lv=vg_tmp_root\/lv_tmp_root/lv=VolGroup00\/LogVol00/g" /boot/grub2/grub.cfg' >> /mnt/grub_installer.sh
echo 'sed -i "s/vg_tmp_root-lv_tmp_root/VolGroup00-LogVol00/g" /boot/grub2/grub.cfg' >> /mnt/grub_installer.sh
chmod +x /mnt/grub_installer.sh
# Генерим /etc/rc.local, который реализует сжатие старого лвм и возврат на него системы
echo '#!/bin/bash' > /mnt/etc/rc.d/rc.local
echo "lvremove -f /dev/VolGroup00/LogVol00" >> /mnt/etc/rc.d/rc.local
echo "yes | lvcreate -n LogVol00 -L 8G VolGroup00" >> /mnt/etc/rc.d/rc.local
echo "mkfs.xfs /dev/VolGroup00/LogVol00" >> /mnt/etc/rc.d/rc.local
echo "mount /dev/VolGroup00/LogVol00 /mnt" >> /mnt/etc/rc.d/rc.local
echo "xfsdump -J - /dev/vg_tmp_root/lv_tmp_root | xfsrestore -J - /mnt" >> /mnt/etc/rc.d/rc.local
echo "for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done" >> /mnt/etc/rc.d/rc.local
echo "chroot /mnt ./grub_installer.sh" >> /mnt/etc/rc.d/rc.local
# Минутка наркомании - чтобы rc.local не выполнился повторно мы его очистим, но перед этим попросим сделать
# дополнительный ребут, чтобы диски получили "правильные" имена
echo 'echo "#!/bin/bash" > /mnt/etc/rc.d/rc.local'
echo 'echo "reboot" >> /mnt/etc/rc.d/rc.local' >> /mnt/etc/rc.d/rc.local
echo 'echo "" > /mnt/etc/rc.d/rc.local' >> /mnt/etc/rc.d/rc.local
echo "reboot" >> /mnt/etc/rc.d/rc.local
chmod +x /mnt/etc/rc.d/rc.local
reboot
