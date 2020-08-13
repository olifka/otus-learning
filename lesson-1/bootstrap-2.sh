#!/bin/bash
cd /tmp && wget -q https://git.kernel.org/torvalds/t/linux-5.8-rc7.tar.gz
tar xf linux-5.8-rc7.tar.gz && rm -rf *gz && cd linux-5.8-rc7

cp /vagrant/make_kernel_config .config

make -j3
echo "Compiling done"
make modules_install
echo "Modules install completed"
make install
echo "Vmlinuz generated"

grub2-mkconfig -o /boot/grub2/grub.cfg
grubby --set-default /boot/vmlinuz-5.8.0-rc7

reboot
exit 0

