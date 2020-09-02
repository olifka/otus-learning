# OTUS Learning
# Урок 6 "Загрузка системы"


# Задача:

Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd


# Решение:

# Попасть в систему без пароля несколькими способами

1. Убрать из опций загрузчика аргументы rhgb, quiet, добавить - rd.break

Добавление этой опции заставляет систему прервать загрузку до монтирования основной корневой системы. В момент, когда мы попадём в консоль, наша корневая система будет в каталоге /sysroot. Надо его перемонтировать с разрешением на запись и chroot'нуться в неё для смены пароля root'а. Примерный листинг команд ниже:
```
# Меняем аргументы загрузчика с помощью grubby.
# То же самое можно сделать из меню grub при старте системы,
# нажав кнопку "e" на нужном образе
grubby --remove-args="rhgb quiet" --update-kernel /boot/vmlinuz-3.10
grubby --args="rd.break" --update-kernel /boot/vmlinuz-3.10
reboot
# Смена пароля
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autolabel
exit
reboot
# После перезагрузки поменять опции grub - убрать rd.break, вернуть rhgb quiet
```

2. Убрать из опций загрузчика аргументы rhgb, quiet, ro, добавить - rw, init=/sysroot/bin/sh

Аргумент init= позволяет поменять систему инициализации по-умолчанию на любую нужную нам. В данном случае - шелл.
Процесс смены пароля аналогичен rd.break, кроме того, что нам не надо будет монтировать директорию /sysroot - она уже будет примонтирована с правами на запись.
```
grubby --remove-args="rhgb quiet ro" --update-kernel /boot/vmlinuz-3.10
grubby --args="rw init=/sysroot/bin/sh" --update-kernel /boot/vmlinuz-3.10
reboot
# Смена пароля
chroot /sysroot
passwd root
touch /.autolabel
exit
reboot
```

3. С использованием Live CD

Грузимся с Live CD, например, Ubuntu. Заходим в консоль и монтируем наш диск с корневой системой. Chrrot'аемся в него, меняем пароль с помощью passwd. Т.к. после изменения файла /etc/passwd у него слетают настройки SELinux, отключаем этот механизм:
```
mount /dev/sda1 /mnt
chroot /mnt
passwd root
sed -i '/s/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
exit
umount /mnt
reboot
```

Все три способа требуют физического доступа к серверу. Rescue- и emergency-modes не перечислил, т.к. оба способа требуют пароль, чтобы попасть в shell

# Установить систему с LVM, после чего переименовать VG
