
$container_exists = docker container ls | Select-String -Quiet -Pattern influxdb_ddos
$network_exists = docker network ls | Select-String -Quiet -Pattern observability-net

if ($container_exists){
    Write-Host "`n deleting old docker influxdb_ddos container"
    docker kill influxdb_ddos
    docker rm influxdb_ddos
}

if ($network_exists){
    Write-Host "`n deleting old docker observability-net network"
    docker network rm observability-net
}



Write-Host "`n creating new network for containers (required for custom IP addr)"
docker network create -d bridge observability-net --subnet=172.18.0.0/16


Write-Host "`n running docker image with influxdb"
docker run -d --name=influxdb_ddos --ip="172.18.0.12" -p 8086:8086  --net=observability-net  -v  /tmp/testdata/influx:/root/.influxdb2 influxdb:2.0
      
Write-Host "`n sleeping for 20s, DB is launching slowly" 
sleep 20   
      
Write-Host "`n seting up credentials & token required for telegraf"       
docker exec -it influxdb_ddos influx setup --org PG --bucket ddos-bucket --username ddos-user  --password ddos-password  --token ddos-token --force 

Write-Host "`n InfluxDB launch completed!"
