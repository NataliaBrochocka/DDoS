!#/bin/bash

apt update
apt -y install netwox
netwox 76 -i $1 -p $2 -s raw

