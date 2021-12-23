echo "Update packages and install make, python3-venv, scapy, tshark"

sudo apt-get update
sudo apt-get install -y make
sudo apt-get install -y python3-venv
sudo apt-get install -y scapy

echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tshark


echo "Installing golang"

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /home/vagrant/tmp_src/go1.17.linux-amd64.tar.gz
echo export PATH=$PATH:/usr/local/go/bin >> /etc/profile


echo "Installing telegraf"

sudo dpkg -i /home/vagrant/tmp_src/telegraf_1.20.0~rc0-1_amd64.deb

