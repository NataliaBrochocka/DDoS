#!/bin/bash

echo "Install tcpreplay"
sudo apt-get install -y tcpreplay

echo "Run tcpreplay"

screen -d -m bash -c "sudo tcpreplay -i enp0s3 -K  --loop=50000 /home/vagrant/traffic_data.pcap"