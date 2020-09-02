#!/bin/bash
mkdir /usr/lib/dracut/modules.d/01test
cd /usr/lib/dracut/modules.d/01test
cp /vagrant/module-setup.sh .
cp /vagrant/test.sh .
chmod +x *.sh
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
echo -e "\n"
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
echo -e "\n"
sleep 5
reboot
