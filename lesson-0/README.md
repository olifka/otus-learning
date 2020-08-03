OTUS Learning
Урок 1 "С чего начинается Linux"


Задача:

Обновить ядро в базовой системе
Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
В материалах к занятию есть методичка, в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.
Для выполнения ДЗ со * и ** вам потребуется сборка ядра и модулей из исходников.
Критерии оценки: Основное ДЗ - в репозитории есть рабочий Vagrantfile с вашим образом.
ДЗ со звездочкой: Ядро собрано из исходников
ДЗ с **: В вашем образе нормально работают VirtualBox Shared Folders


Решение:

Базовое задание- в репозитории есть рабочий Vagrantfile с образом

Практически всё сделано по методичке. Сделал исправления только для packer'а.
В centos.json изменил ссылку на дистрибутив:
https://github.com/olifka/manual_kernel_update/blob/master/packer/centos.json
и в одном из конфигов поменял заполнение файла sudoers:
echo '%vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
(https://github.com/olifka/manual_kernel_update/blob/master/packer/http/vagrant.ks)
*На дефолтоах оно ругалось на синтаксис файла

Задание со звёздочкой - Ядро собрано из исходников

В Vagrantfile (https://github.com/olifka/otus-learning/blob/master/lesson-0/Vagrantfile) включен synced folders,
и совершенно читерски подготовлены:
.config для компляции ядра, Vagrantfile и два скрипта в синхронизируемой папке 

Директивой config.vm.provision :shell, path: провижинер выполняет скрипты bootstrap-1.sh и bootstrap-2.sh
поочереди. 

Первый скрипт (bootstrap-1.sh) устанавливает всё необходимое для сборки ядра и записывает в bash_profile нужную
нам версию gcc: echo "scl enable devtoolset-8 bash" >> ~/.bash_profile

Чтобы перечитать профиль bash я варваски делаю exit...

Скрипт bootstrap-2.sh:
    * скачивает исходники: cd /tmp && wget -q https://git.kernel.org/torvalds/t/linux-5.8-rc7.tar.gz
    * распаковывает их и удаляет архив: tar xf linux-5.8-rc7.tar.gz && rm -rf *gz && cd linux-5.8-rc7
    * копирует подготовленный конфиг из synced folder: cp /vagrant/make_kernel_config .config
    * собирает ядро из исходников * :  make -j3 (система дала только два ядра) && make modules_install && make install
    * настраивает grub: grub2-mkconfig -o /boot/grub2/grub.cfg && grubby --set-default /boot/vmlinuz-5.8.0-rc7 && reboot
