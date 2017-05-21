### Using Portworx volumes with DCOS


Portworx volumes are created, instantiated, and [managed by DCOS](http://mesos.apache.org/documentation/latest/docker-volume/) using [dvdcli]( https://github.com/codedellemc/dvdcli)
dvdcli talks to Portworx using the [docker plugin API](/scheduler/docker/volume_plugin.md)

### Marathon framework

#### Docker containers

See https://github.com/portworx/px-docs/blob/gh-pages/scheduler/mesosphere-dcos/inline.md

### Custom Frameworks:

#### External volumes with custom framework


#### Portworx dcos-commons fork

Portworx fork to dcos-commons allows use of DOCKER volumes in pods.
Added the following config values that can be specified in the yaml file for
pods:
  - docker_volume_driver: Docker driver to be used to mount volumes
  - docker_volume_name: Name of the volume to be used
  - docker_driver_options: Command separated key=value options to be passed to the docker driver

### Failovers
