#!/bin/bash

read -p "Insert VBox guest additions CD..."

groupadd admin
useradd -G admin vagrant
echo vagrant | passwd vagrant --stdin

yum install ntp -y
service ntpd start

yum install sudo wget openssh-server openssh-clients  -y

SUDOERS_FILE="/etc/sudoers"
SUDOERS_RMPNEW="$SUDOERS_FILE.rpmnew"
if [ -f $SUDOERS_RMPNEW ];
then
  mv $SUDOERS_RMPNEW $SUDOERS_FILE
fi 

chkconfig sshd on
service sshd start
echo 'UseDNS no' >> /etc/ssh/sshd_config

cat >> /etc/sudoers << EOF
Defaults    env_keep="SSH_AUTH_SOCK"
%admin ALL=(ALL) ALL
%admin ALL=NOPASSWD: ALL
EOF

sed -ri 's/(Defaults.*!visiblepw)/#\1/g' /etc/sudoers
sed -ri 's/(Defaults.*requiretty)/#\1/g' /etc/sudoers

su - vagrant echo 'export PATH=$PATH:/usr/sbin:/sbin' >> .bashrc


# Install ruby
yum -y groupinstall "Development Tools" 

yum install -y zlib zlib-devel openssl-devel 
cd /tmp
wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar xzvf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure
make
make install

wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
tar zxf ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194
./configure
make
make install

gem update --system
gem install bundler

# Install ssh pubkey
su - vagrant -c "mkdir .ssh; chmod 755 .ssh; wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub ; cat vagrant.pub > .ssh/authorized_keys ; chmod 644 .ssh/authorized_keys"

# Configure networking

for NO in {0..9} 
do
  echo -e "DEVICE=eth$NO\nBOOTPROTO=dhcp\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth$NO
done
echo "" > /etc/udev/rules.d/70-persistent-net.rules

# Install VBox utils
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum install gcc kernel-devel kernel-headers dkms make bzip2 -y

## Current running kernel on Fedora, CentOS 6 and Red Hat (RHEL) 6 ##
KERN_DIR=/usr/src/kernels/`uname -r`

## Current running kernel on CentOS 5 and Red Hat (RHEL) 5 ##
#KERN_DIR=/usr/src/kernels/`uname -r`-`uname -m`

export KERN_DIR

mkdir /media/VirtualBoxGuestAdditions
mount -r /dev/cdrom /media/VirtualBoxGuestAdditions
cd /media/VirtualBoxGuestAdditions
sh ./VBoxLinuxAdditions.run


