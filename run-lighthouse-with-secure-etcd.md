---
layout: page
title: "Run Lighthouse"
keywords: portworx, px-developer, px-enterprise, install, configure, container, storage, lighthouse
sidebar: home_sidebar
---

This guide shows you how you can run [PX-Enterprise Console](http://lighthouse.portworx.com/) locally with secure etcd.

Lighthouse supports etcd2 auth features
1. You can use SSL for connecting to etcd : Use a CA file and/or a Certificate-Key pair
2. You can enable auth in etcd and provide username and password as well. This user should have read/write access to etcd
3. Provide all above options as commandline arguments to docker run command for lighthouse

#### Step #1: Install kvdb with a CA file and/or a Certificate-Key pair

* You can have CA file and/or a Certificate-Key pair for you etcd2 server. There is an example document at [Etcd with Encryption and Authentication] (
https://medium.com/@gargar454/coreos-etcd-and-fleet-with-encryption-and-authentication-27ffefd0785c#.w24dog98z)
* Lighthouse requires that you pass the certs into the container using persistant storage and you map them to '/etc/pwx' path using -v option

#### Step #2: Enable auth in etcd

* You can enable authentication in etcd, using this [guide] (https://coreos.com/etcd/docs/latest/authentication.html)

#### Step #3: Run the PX-Lighthouse container

For **ETCD2**, start the container with the following run command:

```
Sudo docker run -d -p 80:80 -v /etc/ssl:/etc/pwx --restart always  \
-e PWX_KVDB_CA_PATH="/etc/ssl/ca.crt"                              \
-e PWX_KVDB_USER_CERT_KEY_PATH="/etc/ssl/key.key"                  \
-e PWX_KVDB_USER_CERT_PATH="/etc/ssl/key.crt"                      \
-e PWX_KVDB_USER_PWD="etcd2username:password"                      \
-e PWX_KVDB_AUTH="true"                                            \
--name px-lighthouse portworx/px-lighthouse                        \
-d http://admin:password1@${LOCAL_IP}:8086                         \
-k etcd:https://${LOCAL_IP}:2379 
```

Runtime command options

```
-d http://{ADMIN_USER}:{ADMIN_PASSWORD}@{IP_Address}:8086
   > Connection string of your influx db
-k {etcd/consul}:http://{IP_Address}:{Port_NO}
   > Connection string of your kbdb.
   > Note: Specify port 2379 for etcd 
```

The following environment variables are available for px-lighthouse:

```
PWX_KVDB                    KVDB URL:PORT without username:password
PWX_KVDB_AUTH               'true' or 'false', to enable or disable auth 
PWX_KVDB_CA_PATH            Absolute path to host ca cert(e.g. /etc/ssl/ca.crt)
PWX_KVDB_USER_CERT_KEY_PATH Absolute path to host's certificate file (e.g. /etc/pwd/key.cert)
PWX_KVDB_USER_CERT_PATH     Absolute path to host's private key (e.g. /etc/pwd/key.key)
PWX_KVDB_USER_PWD           Username and password for etcd2 as username:password
PWX_INFLUXDB                Influx URL:PORT without username:password
PWX_INFLUXUSR               Influx username
PWX_INFLUXPW                Influx password

(Note: If you are specifying PWX_KVDB_USER_PWD, then PWX_KVDB_AUTH needs to be set as true)
```

In your browser visit *http://{IP_ADDRESS}:80* to access your locally running PX-Lighthouse.

![LH-ON-PREM-FIRST-LOGIN](images/lh-on-prem-first-login-updated_2.png "First Login")
