#!/bin/bash
echo -e "\nlsblk on start:\n"
lsblk
yum -y install mdadm
yes | mdadm --create /dev/md/raid1 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
mkfs.xfs /dev/md/raid1
RAID_UUID=`blkid -o udev /dev/md/raid1|grep ID_FS_UUID=|awk -F "=" '{print $2}'`
HDD_UUID=`blkid -o udev /dev/sda1|grep ID_FS_UUID=|awk -F "=" '{print $2}'`
echo "UUID=$RAID_UUID						xfs	defaults	0 0" > /etc/fstab
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=1/g' /etc/default/grub
sed -i "s/$HDD_UUID/$RAID_UUID/g" /boot/grub2/grub.cfg
echo -e "\nlsblk after RAID creation:\n"
lsblk
mount /dev/md/raid1 /mnt
rsync -aAX --exclude={/dev/*,/mnt/*,/proc/*,/sys/*,/tmp/*,/run/*} / /mnt/
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub2/grub.cfg
# echo '#!/bin/bash' > /mnt/grub_installer.sh
# echo 'grub2-install /dev/sda' >> /mnt/grub_installer.sh
# echo 'sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=1/g' /etc/default/grub' >> /mnt/grub_installer.sh
# echo 'grub2-mkconfig -o /boot/grub2/grub.cfg' >> /mnt/grub_installer.sh
# echo 'exit 0' >> /mnt/grub_installer.sh
# chmod +x /mnt/grub_installer.sh
# chroot /mnt ./grub_installer.sh
rm -rf /mnt/grub_installer.sh
# dd if=/dev/zero bs=1 count=1024 of=/dev/sda
umount -l /mnt/sys
umount -l /mnt/proc
umount -l /mnt/dev
umount -l /mnt
reboot
# exit 0
