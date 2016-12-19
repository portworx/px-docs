---
layout: page
title: "Run on SLES 12 SP1"
keywords: portworx, px-developer, px-enterprise, install, configure, SLES 12, SP1
sidebar: home_sidebar
---

# Install PX container on SLES (SuSe Enterpise Linux) 12SP1

  1. disable suse firewall
  ```
   yast firewall
  ```
  2. install docker module   
  ```
  zypper install docker
  ```
  3. start docker service  
  ```
  sudo systemctl start docker
  ```
  4. Enable docker service
  ```
  sudo systemctl enable docker
  ```
  5. Set up etcd in one of the node; in here we use etcd container 
  ```
  docker run -v /data/varlib/etcd -p 4001:4001 -d portworx/etcd:latest
  ```
  7. Check your local disk with lsblk, this system should minium have one extra disk for PX container.
  In this case, we have two extra disks   
  ```
  /dev/sdb
  /dev/sdc
  ```
  8. Create PX configuration folder and file, in the following the etcd host is running on 10.201.100.161 
  ```
  mkdir -p /etc/pwx   cat  << EOF  > /etc/pwx/config.json
  {  
  "clusterid": "5ac2ed6f-7e4e-4e1d-8e8c-3a6df1fb61a5",
  "kvdb": [
      "etcd:http://10.201.100.161:4001"
          ],
      "storage": {
      "devices": [
      "/dev/sdb",
      "/dev/sdc"
      ]
    }
  }
  EOF
  ```
  9. Before running the PX container; make sure you have kernel-headers, kernel-syms, module-init-tools, kernel-syms installed
  ```
  
  zypper install kernel-devel
  zypper install kernel-syms
  
  ```
  
  Resolve some missing files issue. Due to some header files are in linux-obj folder.
  **Depends on your installed kernel version, on SLES 12 SP1, the updated kernel version could be 3.12.67.60.64.24
  ```
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/include/generated /usr/src/linux-3.12.67-60.64.21/include/generated
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/include/config /usr/src/linux-3.12.67-60.64.21/include/config
  ln -s /usr/src/linux-3.12.67-60.64.21/arch/sh/include/uapi/asm/unistd_64.h /usr/src/linux-3.12.67-60.64.21/arch/x86/include/asm/unistd_64.h
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/arch/x86/include/generated/asm/unistd_64_x32.h /usr/src/linux-3.12.67-60.64.21/arch/x86/include/asm/unistd_64_x32.h
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/arch/x86/include/generated/asm/unistd_32_ia32.h /usr/src/linux-3.12.67-60.64.21/arch/x86/include/asm/unistd_32_ia32.h
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/scripts/recordmcount /usr/src/linux-3.12.67-60.64.21/scripts/recordmcount ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/scripts/basic/fixdep /usr/src/linux-3.12.67-60.64.21/scripts/basic/fixdep
  ln -s /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/scripts/mod/modpost /usr/src/linux-3.12.67-60.64.21/scripts/mod/modpost
  
  cp -p -r /usr/src/linux-3.12.67-60.64.21-obj/x86_64/default/Module.symvers /usr/src/linux/
  ```
  9. Run PX container
  ```
  sudo docker run --restart=always --name px -d --net=host --privileged=true \
  -v /run/docker/plugins:/run/docker/plugins    \
  -v /var/lib/osd:/var/lib/osd:shared           \
  -v /dev:/dev                                  \
  -v /etc/pwx:/etc/pwx                          \
  -v /opt/pwx/bin:/export_bin:shared            \
  -v /var/run/docker.sock:/var/run/docker.sock  \
  -v /var/cores:/var/cores                      \
  -v /usr/src:/usr/src                          \
  --ipc=host                                    \
  portworx/px-dev
  ```
  
  10. Check PX container
  ```
  docker ps -a
  docker logs px
  ```
  11. If everything is OK; you can use pxctl commands 
  ```
  suse01:/ # /opt/pwx/bin/pxctl status
  
  Status: PX is operational
  Node ID: 7ef800f6-d030-4e06-8937-8fed200d0fd0
  IP: 10.201.100.161
  Local Storage Pool: 1 pool
  Pool    Cos             Size    Used    Status  Zone    Region
  0       COS_TYPE_LOW    128 GiB 2.2 GiB Online  default default
  Local Storage Devices: 2 devices
  Device  Path            Media Type              Size            Last-Scan
  0:1     /dev/sdb        STORAGE_MEDIUM_MAGNETIC 64 GiB          15 Dec 16 17:07 PST
  0:2     /dev/sdc        STORAGE_MEDIUM_MAGNETIC 64 GiB          15 Dec 16 17:07 PST
  total                   -                       128 GiB
  Cluster Summary        
  Cluster ID: 5ac2ed6f-7e4e-4e1d-8e8c-3a6df1fb61a3
  Node IP: 10.201.100.161 - Capacity: 2.2 GiB/128 GiB Online(This node)
  Global Storage Pool
  Total Used      :  2.2 GiB
  Total Capacity  :  128 GiB
  ```
  12. Create a docker volume
  ```
  docker volume create -d pxd --name demovolume1 --opt fs=ext4 --opt size=10G
  ```
  ```
  suse01:/ # /opt/pwx/bin/pxctl volume list
  ID                      NAME            SIZE    HA      SHARED  ENCRYPTED       COS             STATUS
  804850618821436883      demovolume1     10 GiB  1       no      no              COS_TYPE_LOW    up - detached
  ```
