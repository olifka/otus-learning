#!/bin/bash
yum -y groupinstall "Development Tools"
yum -y install wget ncurses-devel hmaccalc zlib-devel binutils-devel elfutils-libelf-devel asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc hostname java-devel m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl patch pciutils-devel perl perl-ExtUtils-Embed pesign python-devel python-docutils redhat-rpm-config rpm-build sh-utils tar xmlto xz zlib-devel openssl-devel centos-release-scl-rh

yum -y install devtoolset-8-toolchain

echo "scl enable devtoolset-8 bash" >> ~/.bash_profile

exit 0

