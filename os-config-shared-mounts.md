#OS Configuration for Shared Mounts

The following sections describe how to configure Docker for shared mounts on [CoreOS](coreos-configuration-and-shared-mounts), [CentOS](centos-configuration-and-shared-mounts), and [Ubuntu](ubuntu-configuration-and-shared-mounts). The configuration is required because the Portworx solution exports mount points. The examples use AWS EC2 for servers in the cluster.

##CoreOS Configuration and Shared Mounts

1. Verify that your Docker version is 1.10 or later:
    ~~~
   docker -v
   ~~~
2. Copy the docker.service file for editing:
    ~~~
    sudo cp /usr/lib64/systemd/system/docker.service
    /etc/systemd/system
      ~~~
3. Edit the docker service file for `systemd`:
    ~~~
    sudo vi /etc/systemd/system/docker.service
    ~~~
4. Remove the `MountFlags` line.

5. Reload the daemon:
      ~~~
      sudo systemctl daemon-reload
      ~~~
6. Restart Docker:
      ~~~
      sudo systemctl restart docker
      ~~~

##CentOS Configuration and Shared Mounts

1. Follow the Docker installation guide, [Red Hat Enterprise Linux](https://docs.docker.com/engine/installation/linux/rhel/) and then start the Docker service.

2. Verify that your Docker version is 1.10 or later:
    ~~~
    docker -v
    ~~~

2. Edit the service file for `systemd`:
    ~~~
    sudo vi /lib/systemd/system/docker.service
    ~~~
3. Remove the `MountFlags` line.

4. Reload the daemon:
     ~~~
     sudo systemctl daemon-reload
     ~~~
5. Restart Docker:
     ~~~
     sudo systemctl restart docker
     ~~~

##Ubuntu Configuration and Shared Mounts

1. SSH into your first server.
2. While following the Docker installation guide, [Unbuntu](https://docs.docker.com/engine/installation/linux/ubuntulinux/):

    * Update your apt sources for Ubuntu Trusty 14.04 (LTS).
    * Make sure you use Trusty 14.04 as the deb entry in step 7 when you add an entry for Ubuntu.
    * Install Docker and start the Docker service.


3. Verify that your Docker version is 1.10 or later. In your SSH window, run:
    ~~~
    docker -v
    ~~~
4. In your SSH window, run:
    ~~~
    sudo mount --make-shared /
    ~~~

5. If you are using `systemd`, remove the `MountFlags=slave` line in your docker.service file.

    The Ubuntu in this example is not using `systemd`.
