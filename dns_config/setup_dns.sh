#!/bin/bash

install_utils(){
echo -e "\n--------- Installing bind-utils... ---------"
apt update
apt -y install bind9 bind9utils bind9-doc
}
configure_bind(){
echo -e "\n--------- Confiruing bind for IPv4... ---------"
echo '#
# run resolvconf?
RESOLVCONF=yes

# startup options for the server
OPTIONS="-4 -u bind"' > /etc/default/bind9
echo -e "\n--------- Making files copy from /vagrant/DNS_config to /etc/bind... ---------"
cp /vagrant/DNS_config/named.conf.options /etc/bind/named.conf.options
cp /vagrant/DNS_config/named.conf.local /etc/bind/named.conf.local
cp /vagrant/DNS_config/named.conf /etc/bind/named.conf
cp /vagrant/DNS_config/db.ddos.edu /etc/bind/db.ddos.edu
cp /vagrant/DNS_config/db.27.168.192 /etc/bind/db.27.168.192
echo -e "\n--------- Checking syntax in bind-configuration-files... ---------"
named-checkzone ddos.edu /etc/bind/db.ddos.edu
named-checkzone 192.168.27.9/24 /etc/bind/db.27.168.192
named-checkconf  /etc/bind/named.conf.local 
named-checkconf  /etc/bind/named.conf
systemctl restart bind9
}
firewall_allow(){
  echo -e "\n--------- Creating entry in firewall... ---------"
  apt install iptables -y
  iptables -I INPUT -p tcp --dport 53 -j ACCEPT
  iptables -I INPUT -p udp --dport 53 -j ACCEPT
  iptables -L -v | grep "domain$" >> /dev/null
  iptables_exit_code=$?
  if [ $iptables_exit_code -ne 0 ]; then
    echo "--------- PORT 53 opened successfully ---------"
  else
    echo "--------- Opening PORT failed with exit code: $dns_exit_code ---------"
  fi
}
check_status(){
  nslookup ddos.edu
  dns_exit_code=$?
  nslookup 192.168.27.9
  rev_dns_exit_code=$?
  if [ dns_exit_code -eq 0 ] && [ rev_dns_exit_code -eq 0 ]; then
    echo "--------- DNS configured successfully ---------"
  else
    echo "--------- DNS failed with exit code: $dns_exit_code ---------"
  fi
}
install_utils
configure_bind
firewall_allow
check_status
