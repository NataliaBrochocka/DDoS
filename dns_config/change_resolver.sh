enable_priv_net_dns(){
    HOST_PRIV_IP=$(grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/[0-9]{1,2}" /etc/netplan/50-vagrant.yaml)
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] Enabling DNS in private network.." 
    sudo echo "
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - $HOST_PRIV_IP
      nameservers:
        addresses:
        - 192.168.27.9            # Private IP for DNS
        search: [ ddos.edu ]      # DNS zone
    "> /etc/netplan/50-vagrant.yaml
    netplan apply
    }
disable_pub_net_dns(){
    echo -e "\n----------------------------------------------------------------------"
    echo "[INFO] Disabling DNS in public network.." 
    sudo echo "
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: true
            dhcp4-overrides:
                use-dns: false
    " >> /etc/netplan/50-cloud-init.yaml
    netplan apply
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
}
check_status(){
    nslookup ns.ddos.edu
    dns_exit_code=$?
    if [ $dns_exit_code -eq 0 ];then
        echo -e "\n----------------------------------------------------------------------"
        echo -e "[INFO] Resolver changed to private DNS.."
        systemd-resolve --status
    else
        echo -e "\n----------------------------------------------------------------------"
        echo -e "\033[0;31m[FAIL]\033[0m Resolver change failed with exit code: $dns_exit_code"
    fi
}
main(){
    echo -e "################# Changing resolver to private DNS.. #################"
    sudo su
    enable_priv_net_dns
    disable_pub_net_dns
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    exit
    check_status
}
main


