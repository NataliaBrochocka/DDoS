#!/bin/bash

# text formatting
bold=$(tput bold)
normal=$(tput sgr0)


echo -e "\n${bold}checking if some old container exists, if yes - deleting them${normal}"
if docker container ls -a |grep influxdb_ddos; then
    docker kill influxdb_ddos
    docker rm influxdb_ddos
fi

echo -e "\n${bold}checking if some old network exists, if yes - deleting them${normal}"
if docker network ls |grep observability-net; then
    docker network rm observability-net
fi

echo -e "\n${bold}creating new network for containers (required for custom IP addr)${normal}"
docker network create -d bridge observability-net --subnet=172.18.0.0/16


echo -e "\n${bold}running docker image with influxdb${normal}"
docker run -d --name=influxdb_ddos \
 --ip="172.18.0.12" \
 -p 8086:8086 \
 --net=observability-net \
 -v  /tmp/testdata/influx:/root/.influxdb2 \
      influxdb:2.0
      
echo -e "\n${bold}sleeping for 20s, DB is launching slowly${normal}" 
sleep 20s     
      
echo -e "\n${bold}seting up credentials & token required for telegraf${normal}"       
docker exec -it influxdb_ddos influx setup \
  --org PG \
  --bucket ddos-bucket \
  --username ddos-user \
  --password ddos-password \
  --token ddos-token \
  --force 

echo -e "\n${bold}InfluxDB launch completed!${normal}"
