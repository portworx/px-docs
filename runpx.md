```
# docker run -d --restart=always --name px --net=host          \
                 -v /run/docker/plugins:/run/docker/plugins                 \
                 -v /var/lib/osd:/var/lib/osd:shared                        \
                 -v /dev:/dev                                               \
                 -v /etc/pwx:/etc/pwx                                       \
                 -v /opt/pwx/bin:/export_bin:shared                         \
                 -v /var/run/docker.sock:/var/run/docker.sock               \
                 -v /mnt:/mnt:shared                                        \
                 -v /var/cores:/var/cores                                   \
                 -v /usr/src:/usr/src                                       \
                portworx/px-enterprise -daemon -k etcd:http://myetcd.mycompany.com:2379 -c mycluster-01 -s /dev/vdb
```
