#!/bin/bash
echo -e "\nlsblk on start:\n"
lsblk
yum -y install mdadm
mdadm --create /dev/md/raid0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
mkfs.xfs /dev/md/raid0
RAID_UUID=`blkid -o udev /dev/md/raid0|grep ID_FS_UUID=|awk -F "=" '{print $2}'`
echo -e "\nRAID UUID = $RAID_UUID\n"
echo "UUID=$RAID_UUID						xfs	defaults	0 0" > /etc/fstab
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
echo -e "\nlsblk after RAID creation:\n"
lsblk
mount /dev/md/raid0 /mnt
rsync -aAX --exclude={/dev/*,/mnt/*,/proc/*,/sys/*,/tmp/*,/run/*} / /mnt/
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
# chroot /mnt
grub2-install /dev/sda
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=1/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
# exit 0
# umount /mnt/sys
# umount /mnt/proc
# umount /mnt/dev
# umount /mnt
reboot
