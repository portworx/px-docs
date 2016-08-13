---
layout: page
title: "Portworx Documentation"
sidebar: home_sidebar
---
# Run the Docker Registry with High Availability

The Docker Registry is a server-side application that stores and lets you distribute Docker images. The following instructions use Docker Registry version 2.3.0.

## Step 1: Create a storage volume for the Docker Registry
To create a storage volume for the Docker Registry, run the following command on each server and make a note of the returned volume ID. You will need the volume ID when you start the Registry container in the next step.

```
docker volume create -d pxd --opt name=registry_volume --opt \
    size=4 --opt block_size=64 --opt repl=3 --opt fs =ext4
```

That command creates a volume to attach to your Docker Registry container. The Docker Registry stores its data in the /tmp/registry directory. Use the Docker `-v` option to attach the Portworx volume to this directory.  

If you don't have the Registry image available locally, you can pull it with `docker pull registry`.

## Step 2: Start the Docker Registry
To start the Docker Registry, run the following command. Substitute `DOCKER_CREATE_VOLUME_ID` for the volume id from the `docker volume create` command.

```
docker run -d -p 5000:5000  --name registry \
    -v DOCKER_CREATE_VOLUME_ID:/tmp/registry registry:2.3.0
```

Your Docker Registry is now available for Docker push and pull commands on port 5000.
