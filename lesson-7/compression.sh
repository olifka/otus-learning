#!/bin/bash

function calculate_zfs_space {
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
echo -e "\rDownloading sample file (the 'World & Peace')..."
wget -q -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
echo -e "\rCopying sample file to zfs-directories..."
xargs -n 1 cp War_and_Peace.txt<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\rCalculating located space..."
calculate_zfs_space
echo -e "\rCopying /usr/share/man to zfs-directories..."
xargs -n 1 cp -r /usr/share/man<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\rCalculating located space..."
calculate_zfs_space
echo -e "\rCopying /usr/bin to zfs-directories..."
xargs -n 1 cp -r /usr/bin<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\rCalculating located space..."
calculate_zfs_space

  # # #  # # #
 #  Task 2  #
# # #  # # #
echo -e "\rCreating 10Mb dummy filled with zeros..."
dd if=/dev/zero of=/tmp/0dummy bs=1 count=10000000
du -hs /tmp/0dummy
echo -e "\rCopying 0dummy to zfs-directories..."
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/ /mnt/lz4/ /mnt/lzjb/ /mnt/zle/ /mnt/dedup/"
echo -e "\rCalculating located space..."
calculate_zfs_space
echo -e "\rCopying 0dummy to zfs-directories by 5 times..."
touch /mnt/gzip9/0dummy0
touch /mnt/lz4/0dummy1
touch /mnt/lzjb/0dummy2
touch /mnt/zle/0dummy3
touch /mnt/dedup/0dummy4
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/0dummy0 /mnt/lz4/0dummy0 /mnt/lzjb/0dummy0 /mnt/zle/0dummy0 /mnt/dedup/0dummy0"
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/0dummy1 /mnt/lz4/0dummy1 /mnt/lzjb/0dummy1 /mnt/zle/0dummy1 /mnt/dedup/0dummy1"
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/0dummy2 /mnt/lz4/0dummy2 /mnt/lzjb/0dummy2 /mnt/zle/0dummy2 /mnt/dedup/0dummy2"
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/0dummy3 /mnt/lz4/0dummy3 /mnt/lzjb/0dummy3 /mnt/zle/0dummy3 /mnt/dedup/0dummy3"
xargs -n 1 cp /tmp/0dummy<<<"/mnt/gzip9/0dummy4 /mnt/lz4/0dummy4 /mnt/lzjb/0dummy4 /mnt/zle/0dummy4 /mnt/dedup/0dummy4"
echo -e "\rCalculating located space..."
calculate_zfs_space

echo -e "\rDownloading archive with test zpool..."
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O zfs_task1.tar.gz
echo -e "\rUnarchiving..."
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
