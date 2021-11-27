#!/bin/bash

install_utils(){
  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Installing bind-utils.."
  apt update
  apt -y install bind9 bind9utils bind9-doc
}
configure_bind(){
  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Configuring bind for IPv4.."
echo '#
# run resolvconf?
RESOLVCONF=yes

# startup options for the server
OPTIONS="-4 -u bind"' > /etc/default/bind9

  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Making files copy from /vagrant/dns_config to /etc/bind.."
  cp /vagrant/dns_config/named.conf.options /etc/bind/named.conf.options
  cp /vagrant/dns_config/named.conf.local /etc/bind/named.conf.local
  cp /vagrant/dns_config/named.conf /etc/bind/named.conf
  cp /vagrant/dns_config/db.ddos.edu /etc/bind/db.ddos.edu
  cp /vagrant/dns_config/db.27.168.192 /etc/bind/db.27.168.192

  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Checking syntax in bind-configuration-files.."
  named-checkzone ddos.edu /etc/bind/db.ddos.edu
  named-checkzone 27.168.192.in-addr.arpa /etc/bind/db.27.168.192
  named-checkconf  /etc/bind/named.conf.local 
  named-checkconf  /etc/bind/named.conf

  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Changing /etc/resolv.conf entry.."
echo "
nameserver 192.168.27.9
search ddos.edu
" > /etc/resolv.conf

  systemctl restart bind9
}
firewall_allow(){
  echo -e "\n----------------------------------------------------------------------"
  echo -e "[INFO] Creating entry in firewall.."
  apt -y install iptables
  iptables -I INPUT -p tcp --dport 53 -j ACCEPT
  iptables -I INPUT -p udp --dport 53 -j ACCEPT
  iptables -L -v | grep "domain$" >> /dev/null
  iptables_exit_code=$?
  if [ $iptables_exit_code -eq 0 ]; then
    echo -e "\n----------------------------------------------------------------------"
    echo "[INFO] Port 53 had been opened"
  else
    echo -e "\n----------------------------------------------------------------------"
    echo "\033[0;31m[FAIL]\033[0m firewall entry failed with exit code: $dns_exit_code"
  fi
}
check_status(){
  nslookup ns.ddos.edu
  dns_exit_code=$?
  nslookup 192.168.27.9
  rev_dns_exit_code=$?
  if [ $dns_exit_code -eq 0 ] && [ $rev_dns_exit_code -eq 0 ]; then
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] DNS configured successfully"
  else
    echo -e "\n----------------------------------------------------------------------"
    echo -e "\033[0;31m[FAIL]\033[0m DNS failed with exit code: $dns_exit_code"
  fi
}
main(){
  echo -e "\n###################### Setting up DNS server.. ######################"
  install_utils
  configure_bind
  firewall_allow
  check_status
}
main
