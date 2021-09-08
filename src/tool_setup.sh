echo "Update packages and install make, python3-venv"

sudo apt-get update
sudo apt-get install -y make
sudo apt-get install -y python3-venv

echo "Download and install golang"

wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
echo export PATH=$PATH:/usr/local/go/bin >> /etc/profile


echo "Download and install telegraf"

wget https://dl.influxdata.com/telegraf/releases/telegraf_1.20.0~rc0-1_amd64.deb
sudo dpkg -i telegraf_1.20.0~rc0-1_amd64.deb
