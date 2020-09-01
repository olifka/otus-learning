#!/bin/bash
# Устанавливаем необходимые для сборки и создания репозитория пакеты
yum -y install wget unzip glibc-static yum-utils rpmdevtools openssl-devel zlib-devel pcre-devel createrepo
yum groupinstall -y "Development Tools"
cd /root
# Скачиваем модуль nginx, которым будем патчить программу - это наша кастомизация
wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/master.zip
unzip master.zip && rm -rf master.zip
# Скачиваем исходники nginx
rpm -Uvh http://nginx.org/packages/centos/7/SRPMS/nginx-1.16.1-1.el7.ngx.src.rpm
rm -rf nginx-1.16.1-1.el7.ngx.src.rpm
# Создаём папку с окружением под сборку
rpmdev-setuptree
cd /root/rpmbuild/SOURCES
# Распаковываем исходники nginx
tar xf nginx-1.16.1.tar.gz && rm -rf nginx-1.16.1.tar.gz
cd nginx-1.16.1
# И применям патч для модуля upstream_check
patch -p1 < ../../../nginx_upstream_check_module-master/check_1.16.1+.patch
cd ..
# Пакуем исходники обратно в тарболл
tar czf nginx-1.16.1.tar.gz nginx-1.16.1 && rm -rf nginx-1.16.1
# Копируем в папку со спекой подготовленную спецификацию
# Отличается от оригинальной строкой "--add-module=/root/nginx_upstream_check_module-master"
cd /root/rpmbuild/SPECS
cp /vagrant/nginx.spec .
# Собираем наш кастомный rpm с nginx
rpmbuild -bb nginx.spec
# Начинаем готовить наш веб-репозиторий. Веб-сервер установим свой собственный свежесобранный
rpm -ivh /root/rpmbuild/RPMS/x86_64/nginx-1.16.1-1.el7.ngx.x86_64.rpm
# Добавим nginx в автозагрузку и включим фаервол
systemctl enable nginx
systemctl enable firewalld
systemctl start firewalld
# Откроем необходимые для работы веб-сервера порты
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
# Отключаем selinux, чтобы не заморачиваться с настройками доступности файлов
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# Создаём дерикторию, где будут храниться наши пакеты и куда будет смотреть nginx
mkdir -p /var/www/html/repos
# Копируем заранее подготовленный конфиг для nginx
cp /vagrant/repos.conf /etc/nginx/conf.d/.
# Копируем собранный пакет в папку будущего репозитория
cp /root/rpmbuild/RPMS/x86_64/nginx-1.16.1-1.el7.ngx.x86_64.rpm /var/www/html/repos/.
# Активируем репозиторий в папке /var/www/html/repos командой createrepo
createrepo --update /var/www/html/repos/
# Запускаем nginx, чтобы клиент мог к нам подключиться и скачать наш пакет
systemctl start nginx
exit 0
