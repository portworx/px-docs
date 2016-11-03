#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check arguments
args=("$@")

if [ -z "$1" ] ; then
 echo "You must pass a device or partition argument."
 exit 0;
else
 thedevice=$1
 echo "Checking device ${thedevice}"
fi

# Stopping docker (needs to be fixed to support non systemd systems)
/bin/systemctl stop docker

# Install LVM2 Packages
if yum -q list installed "lvm2" >/dev/null 2>&1; then
  echo "LVM2 is already installed"
else
 echo "Making sure lvm2 is installed."
 yum -y install lvm2
fi

# Confirm device
read -p "Are you sure you want to use device $1. All existing data will be lost. Y/y?"  -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    echo "Continuing with $1."
else
  
    echo "Exiting."
    exit 1
fi

# Init device
if ! /sbin/pvcreate $thedevice | grep -q 'successfully created'; then
    echo "Check that device $thedevice is not already in use. Exiting."
    exit;
fi


# Create Volume Group
if ! /sbin/vgcreate docker $thedevice | grep -q 'successfully created'; then
   echo "Check that device $thedevice is not already in use. Exiting."
   exit;
fi

# Create logical volumes
/sbin/lvcreate --wipesignatures y -n thinpool docker -l 95%VG
/sbin/lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG

/sbin/lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

# Create  thinpool.profile
echo "Creating docker-thinpool.profile file in /etc/lvm/profile."
cat << EOF > /etc/lvm/profile/docker-thinpool.profile
activation {
     thin_pool_autoextend_threshold=80
     thin_pool_autoextend_percent=20
 }
EOF

# Apply new lvm changes
/sbin/lvchange --metadataprofile docker-thinpool docker/thinpool

# Making changes to /etc/docker/daemon.json
/bin/mkdir /etc/docker
cat << EOF > /etc/docker/daemon.json
{
         "storage-driver": "devicemapper",
         "storage-opts": [
                 "dm.thinpooldev=/dev/mapper/docker-thinpool",
                 "dm.use_deferred_removal=true"
         ]
}
EOF

echo "Last step. rm -rf /var/lib/docker/* then restart docker daemon."

exit 0;
