
# Deploy 3 node cassandra cluster with Docker Swarm
                         
## Create overlay network
```                     
docker network create --driver overlay --scope swarm cassandra-net
```  
## Create cassandra volumes
```
docker volume create -d pxd --name cassandra1-vol --opt size=4 --opt block_size=64 --opt repl=2 --opt fs=ext4 
docker volume create -d pxd --name cassandra2-vol --opt size=4 --opt block_size=64 --opt repl=2 --opt fs=ext4 
docker volume create -d pxd --name cassandra3-vol --opt size=4 --opt block_size=64 --opt repl=2 --opt fs=ext4 
```
## download and deploy cassandra 3 node compose file
```
wget https://raw.githubusercontent.com/portworx/px-docs/gh-pages/scheduler/docker/portworx-cassandra3node.yaml
```
```
docker stack deploy --compose-file portworx-cassandra3node.yaml cassandra        
```                          
