### Using Portworx volumes with DCOS


Portworx volumes are created, instantiated, and [managed by DCOS](http://mesos.apache.org/documentation/latest/docker-volume/) using [dvdcli]( https://github.com/codedellemc/dvdcli)
dvdcli talks to Portworx using the docker plugin API, see here to understand Portworx implementation of the [API](/scheduler/docker/volume_plugin.md)

### Marathon framework

#### Docker containers

Here's how you would specify Portworx as a volume driver
```
TaskInfo {
  ...
  "command" : ...,
  "container" : {
    "volumes" : [
      {
        "container_path" : "/date",
        "mode" : "RW",
        "source" : {
          "type" : "DOCKER_VOLUME",
          "docker_volume" : {
            "driver" : "pxd",
            "name" : "px_vol"
          }
        }
      }
    ]
  }
}
```

If the volume `px_vol` does not already exist, a new volume with default parameters will be created. Heres's how you can specify inline paramters for volume creation:
See https://github.com/portworx/px-docs/blob/gh-pages/scheduler/mesosphere-dcos/inline.md


### Custom Frameworks:

#### External volumes with custom framework


#### Portworx dcos-commons fork

Portworx [fork to dcos-commons[(https://github.com/portworx/dcos-commons) allows use of DOCKER volumes in pods.
The following config values that can be specified in the yaml file for pods:
  - docker_volume_driver: Docker driver to be used to mount volumes
  - docker_volume_name: Name of the volume to be used
  - docker_driver_options: Command separated key=value options to be passed to the docker driver


### Failovers
