---
layout: page
title: "Cleaning up frameworks on DCOS"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra
meta-description: "Follow these two steps to clean up the resources in DCOS after destroying a service. We're cleaning a cassandra-px service in this example."
redirect_from: "/scheduler/mesosphere-dcos/framework_cleanup.html"
---

* TOC
{:toc}

You will have to run the following steps after destroying a service to clean up all the resources in DCOS.  We are going to clean up the cassandra-px
service in this example. These steps can be used to clean up any service in DCOS including the Portworx service.

## 1. Shutdown the service if it is still running

Run `dcos service --inactive` to find the ID of the service that you want to cleanup. The service should in inactive state,
ie ACTIVE should be set to False.

```
$ dcos service --inactive
NAME                     HOST            ACTIVE  TASKS  CPU    MEM      DISK   ID                                         
cassandra-px  ip-10-0-2-15.ec2.internal   False     2    6.7  27530.0  59890.0  cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0051  
marathon              10.0.4.203          True     4    3.1   3200.0    0.0    cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0001  
metronome             10.0.4.203          True     0    0.0    0.0      0.0    cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0000  
portworx      ip-10-0-2-15.ec2.internal   True     6    1.8   5632.0  16384.0  cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0050 
```

Then use the `dcos service shutdown` command to shutdown the service

```
$ dcos service shutdown cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0051
```

## 2. Run the janitor script to clean up the reserved resources as well as any state stored in Zookeeper
```
$ SERVICE_NAME=cassandra-px
$ dcos node ssh --master-proxy --leader "docker run mesosphere/janitor /janitor.py -r ${SERVICE_NAME}-role -p ${SERVICE_NAME}-principal -z dcos-service-${SERVICE_NAME}"
```

## 3. Cleanup PX remnants from slave nodes

Stop the portworx service on all the nodes and remove the docker container
```
sudo systemctl stop portworx
sudo docker rm portworx.service -f
```

Remove the portworx service file from all the nodes
```
sudo rm /etc/systemd/system/portworx.service -f
sudo rm /etc/systemd/system/dcos.target.wants/portworx.service -f
sudo systemctl daemon-reload
```
		
Remove the Portworx config from all the nodes
```
rm -rf /etc/pwx
```

Also remove the Portworx kernel module from all the nodes
```
sudo rmmod px -f
```

NOTE: If you are going to re-install Portworx, you should wipe out the filesystem from the disks so that they can be picked 
up by Portworx in the next install. This can be done by running the wipefs command
```
# Use with care since this will wipe data from that disk
sudo wipefs -a /dev/sda123 # Replace with your disk names
```

If you have the dcos cli installed then you can execute the above steps on all the nodes by running the following script
```
ips=( `dcos node --json | jq ' .[]' | jq .id -r` )
for ip in "${ips[@]}"
do
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl stop portworx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo docker rm portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm /etc/systemd/system/portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm /etc/systemd/system/dcos.target.wants/portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl daemon-reload'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -rf /etc/pwx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rmmod px -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo wipefs -a /dev/sda123' # Replace with your disk names
done
```

