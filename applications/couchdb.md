## Running Couchdb 2.0 with PX

### Launch Couchdb containers
Deploy couchdb 2.0 using PX volume; create a simple PX volume ``couch_vol01``

    docker run --name couchdb-001 -d \
            -v couch_vol01:/opt/couchdb/data \
            -p 5984:5984         \
            -p 4369:4369         \
            -p 9100:9100         \
            rluiarch/couchdb2:001

Couchdb Web API use tcp port ``5984`` and couchdb app runs on port ``5986``. Most of the couchdb operation involves REAT API port ``5984`` and couchdb cluster setup use port 5986. The docker image ``rluiarch/couchdb2:001`` is build from official couchdb 2.0 [Docker file on github](https://github.com/apache/couchdb-docker/tree/master/2.0.0).

In Couchdb 2.0; four system databases ( "_users", "_replicator", "_metadata", "_global_changes" ) wasn't created by default and errors will be observed from docker logs; therefore these database need to be created after the couchdb container is up and running

    curl -X PUT http://127.0.0.1:5984/_users
    curl -X PUT http://127.0.0.1:5984/_replicator
    curl -X PUT http://127.0.0.1:5984/_metadata
    curl -X PUT http://127.0.0.1:5984/_global_changes


Set up the admin user id/password; the default admin id is "admin" ; get into the couchdb docker container and use couchdb REAT API to add the admin user 
     
     docker exec -it  couchdb-container-name bash
     curl -X PUT http://admin:password@localhost:5986/_config/admins/admin -d '"password"'
 
 you can also create  or change the admin ID / password from webUI

![](images/couchdb-pic-001.PNG)


### Creating test database 

Create three test couchdb database for testing purpose

    curl -X PUT http://admin:password@127.0.0.1:5984/testdb101
    curl -X PUT http://admin:password@127.0.0.1:5984/testdb102
    curl -X PUT http://admin:password@127.0.0.1:5984/testdb103

Use the testscript to inject documents into those test databases. The test script ``test-insert-001.sh`` will insert 1000 X 500 bytes documents into the target couchdb database.

And ``test-run.sh`` script will run parallel multiple of the above script processes. Below the example will run 100,200, and 300 jobs of 1000 document insertion into the target database testdb101, testdb102, and testdb103.


    ./test-run.sh 100 testdb101 
    ./test-run.sh 200 testdb102
    ./test-run.sh 300 testdb103


The following is the performance test result for  PX (single volume repl=1, ``locally attached``, ``remotely attached``) vs Standard local disk in ext4  (baseline) on Couchdb 2.0 (no couchdb replication and sharding).


![](images/couchdb-pic-002.PNG)
