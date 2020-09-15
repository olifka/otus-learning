#!/bin/bash

calculate_zfs_space {
    sleep 3
    du -hs -B1 /mnt/gzip9/ > file_size
    du -hs -B1 /mnt/lz4/ >> file_size
    du -hs -B1 /mnt/lzjb/ >> file_size
    du -hs -B1 /mnt/zle/ >> file_size
    du -hs -B1 /mnt/dedup/ >> file_size
    sort -u file_size
}

  # # #  # # #
 #  Task 1  #
# # #  # # #
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
echo -e "\nDownloading sample file (the 'World & Peace')...\n"
wget -q -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
echo -e "\nCopying sample file to zfs-directories...\n"
xargs -n 1 cp War_and_Peace.txt<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\nCalculating located space...\n"
calculate_zfs_space
echo -e "\nCopying /usr/share/man to zfs-directories...\n"
xargs -n 1 cp -r /usr/share/man<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\nCalculating located space...\n"
calculate_zfs_space
echo -e "\nCopying /usr/bin to zfs-directories...\n"
xargs -n 1 cp -r /usr/bin<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\nCalculating located space...\n"
calculate_zfs_space

  # # #  # # #
 #  Task 2  #
# # #  # # #
echo "\Creating 10Mb dummy filled with zeros...\n"
dd if=/dev/zero of=/tmp/0dummy -bs=1 -count=10000000
echo -e "\nCopying 0dummy to zfs-directories...\n"
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\nCalculating located space...\n"
calculate_zfs_space

echo -e "\nDownloading archive with test zpool...\n"
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O zfs_task1.tar.gz
echo -e "\nUnarchiving...\n"
tar xf zfs_task1.tar.gz
zpool import -d zpoolexport otus
zpool get size otus
# zpool get all otus|grep size
# NAME  PROPERTY  VALUE  SOURCE
# otus  size      480M   -
zpool history otus|grep create
# 2020-05-15.04:00:58 zpool create otus mirror /root/filea /root/fileb
zpool history otus|grep checksum
# 2020-05-15.04:05:55 zfs set checksum=sha256 otus
zpool history otus|grep compression
# 2020-05-15.04:11:05 zfs set compression=zle otus

exit 0
