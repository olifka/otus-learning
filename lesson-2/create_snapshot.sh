#!/bin/bash
# Создаём тестовые файлы
touch /home/vagrant/4remove1
touch /home/vagrant/4remove2
touch /home/vagrant/not4remove1
touch /home/vagrant/not4remove2
echo -e "Test files created. Current content of /home/vagrant:\n"
ls /home/vagrant
echo -e "\n"
sleep 3
# Делаем снэпшот хомяка
lvcreate -s -n lv_home_snap -L 1.9G /dev/VolGroup01/lv_home
# Удаляем тестовые файлы
rm -rf /home/vagrant/4remove*
echo -e "Test files removed. Current content of /home/vagrant:\n"
ls /home/vagrant
sleep 3
echo -e "\nStarting merging snapshot\n"
# Запускаем мердж снэпшота
lvconvert --merge /dev/VolGroup01/lv_home_snap
sleep 3
# После перезагрузке в домашней папке снова будут все 4 файла
reboot
