
# Deploy 3 node cassandra cluster with Docker Swarm
                         
## Create overlay network
```                     
docker network create --driver overlay --scope swarm cassandra-net
```   

## Download and deploy cassandra 3 node compose file
```
wget https://raw.githubusercontent.com/portworx/px-docs/gh-pages/scheduler/docker/portworx-cassandra3node.yaml
```
```
docker stack deploy --compose-file portworx-cassandra3node.yaml cassandra        
```                          
