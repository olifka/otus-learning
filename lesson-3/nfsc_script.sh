#!/bin/bash
mkdir /nfs_share
yum -y install nfs-utils
cp /vagrant/nfsc-unit /lib/systemd/system/nfs_share.mount
echo "192.168.50.10:/var/nfs_share /nfs_share nfs vers=3,udp,x-systemd.requires-mounts-for=/nfs_share      0  0" >> /etc/fstab
systemctl daemon-reload
mount -a
mkdir /nfs_share/upload
chown -R vagrant:vagrant /nfs_share/upload
exit 0
