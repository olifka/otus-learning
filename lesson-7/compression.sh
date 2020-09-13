#!/bin/bash

yum -y install http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
yum-config-manager --enable zfs-kmod
yum-config-manager --enable zfs
yum -y install zfs wget
modprobe zfs

zpool create gzip9 /dev/sdb
zpool create lz4 /dev/sdc
zpool create lzjb /dev/sdd
zpool create zle /dev/sde
zpool create dedup /dev/sdf

mkdir /mnt/gzip9
mkdir /mnt/lz4
mkdir /mnt/lzjb
mkdir /mnt/zle
mkdir /mnt/dedup

zfs create gzip9/data
zfs create lz4/data
zfs create lzjb/data
zfs create zle/data
zfs create dedup/data

zfs set mountpoint=/mnt/gzip9 gzip9/data
zfs set mountpoint=/mnt/lz4 lz4/data
zfs set mountpoint=/mnt/lzjb lzjb/data
zfs set mountpoint=/mnt/zle zle/data
zfs set mountpoint=/mnt/dedup dedup/data

zfs set compress=gzip-9 gzip9/data
zfs set compress=lz4 lz4/data
zfs set compress=lzjb lzjb/data
zfs set compress=zle zle/data
zfs set dedup=on dedup/data

cd /tmp
echo -e "\nDownloading sample file...\n"
wget -q -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
xargs -n 1 cp -v War_and_Peace.txt<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"

echo -e "\nWating for zfs to make it's cool fings...\n"
sleep 5

du -s -B1 /mnt/gzip9/ > file_size
du -s -B1 /mnt/lz4/ >> file_size
du -s -B1 /mnt/lzjb/ >> file_size
du -s -B1 /mnt/zle/ >> file_size
du -s -B1 /mnt/dedup/ >> file_size

sort -u file_size
# 1213952 /mnt/gzip9/
# 1214464 /mnt/lz4/
# 1214464 /mnt/zle/
# 1220608 /mnt/lzjb/
# 1314816 /mnt/dedup/
exit 0
