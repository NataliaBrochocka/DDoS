#!/bin/bash

if [ ! -f ./tmp_src/go1.17.linux-amd64.tar.gz ]; then
    echo "Downloading go"
    wget https://golang.org/dl/go1.17.linux-amd64.tar.gz --directory-prefix=./tmp_src
else
    echo "Go for VM's is already downloaded"
fi

if [ ! -f ./tmp_src/telegraf_1.20.0~rc0-1_amd64.deb ]; then
    echo "Downloading telegraf"
    wget https://dl.influxdata.com/telegraf/releases/telegraf_1.20.0~rc0-1_amd64.deb --directory-prefix=./tmp_src
else
    echo "Telegraf for VM's is already downloaded"
fi


