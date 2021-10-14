
add_dns_to_priv_net(){

    echo "
        nameservers:
            addresses:
            - 192.168.27.9            # Private IP for DNS
            search: [ ddos.edu ]      # DNS zone
    ">> /etc/netplan/50-vagrant.yaml
    netplan apply
    }
disable_dns_in_public(){
    sudo su
    sudo echo "
    network:
        version: 2
        ethernets:
            enp0s3:
                dhcp4: true
                dhcp4-overrides:
                    use-dns: false
                match:
                    macaddress: 02:2f:77:f1:0c:e0
                set-name: enp0s3
    " > /etc/netplan/50-cloud-init.yaml
    netplan apply
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    exit
}
echo_dns(){
nslookup ddos.edu
nslookup_exit_code=$?
if [ $nslookup_exit_code -eq 0 ]; then
    echo "DNS server changed to: 
    $(cat /etc/resolv.conf | egrep '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | cut -f2 -d' ')" 
fi
}
add_dns_to_priv_net
disable_dns_in_public
echo_dns


