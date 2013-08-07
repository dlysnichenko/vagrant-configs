#!/bin/bash
groupadd admin
useradd -G admin vagrant
echo vagrant | passwd vagrant --stdin

yum install ntp -y
service ntpd start

yum install sudo wget openssh-server openssh-clients  -y

chkconfig sshd on
service sshd start
echo 'UseDNS no' >> /etc/ssh/sshd_config

cat >> /etc/sudoers << EOF
Defaults    env_keep="SSH_AUTH_SOCK"
%admin ALL=(ALL) ALL
%admin ALL=NOPASSWD: ALL
EOF

sed -i 's/Defaults   !visiblepw/#Defaults   !visiblepw/g' /etc/sudoers
sed -i 's/Defaults   requiretty/#Defaults   requiretty/g' /etc/sudoers

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
su - vagrant mkdir .ssh; chmod 755 .ssh; wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub ; cat vagrant.pub > .ssh/authorized_keys ; chmod 644 .ssh/authorized_keys 

# ? ifconfig?
sudo /sbin/ifconfig
echo "write down MAC address of eth0"

shutdown -h now

# Не потрібне?
# install from EPEL
#yum --enablerepo=epel -y install libyaml libyaml-devel readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel libffi-devel

#mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} 
#wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p385.tar.gz -P rpmbuild/SOURCES 
#wget https://raw.github.com/imeyer/ruby-1.9.3-rpm/master/ruby19.spec -P rpmbuild/SPECS 
#rpmbuild -bb rpmbuild/SPECS/ruby19.spec 
#rpm -Uvh rpmbuild/RPMS/x86_64/ruby-1.9.3p385-1.el6.x86_64.rpm 
 


#yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel openssh-server openssh-clients

#chkconfig sshd on
#service sshd start

