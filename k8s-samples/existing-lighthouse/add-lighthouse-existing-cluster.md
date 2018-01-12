## Add Lighthouse to an existing portworx cluster

### Download and install the lighthouse

Step 1: Download the [lighthouse yaml](https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/existing-lighthouse/k8-lighthouse.yaml):

```
wget https://raw.githubusercontent.com/portworx/px-docs/gh-pages/k8s-samples/existing-lighthouse/k8-lighthouse.yaml
```

Step 2: Edit `k8-lighthouse.yaml` and change the `etcd` entry to your existing etcd service where portworx is currently running:

```
        - etcd:http://<etcd server>:<ETCD PORT>
```

>**Note:**<br/> You can check `/etc/pwx/config.json` file to find your etcd service IP and Port info (ie. `grep -A2 kvdb /etc/pwx/config.json`)


Step 3: Change the COMPANY NAME and ADMIN EMAIL 

```
       - name: PWX_PX_COMPANY_NAME
          value: <COMPANY NAME>
       - name: PWX_PX_ADMIN_EMAIL
          value: <ADMIN EMAIL>
```

Step 4: Deploy Lighthouse 

```
kubectl apply -f k8-lighthouse.yaml
```

Step 5: Login to Lighthouse at port 30062 

```
http://<Your k8 Master>:30062
```

>**Note:**<br/> Login username will be the email address you supplied for ADMIN EMAIL, while the default password is "admin".


### Creating a new PX cluster

Step 1: Click on create new cluster

Step 2: Click on existing cluster and in both name and clusterid insert the name of your portworx cluster and click on create. Screen shot can be found [here](https://github.com/portworx/px-docs/blob/gh-pages/k8s-samples/existing-lighthouse/new-cluster.png)   If you do not know the name look in `/etc/pwx/config.json`

Step 3: Once the cluster is created it will show a token for the cluster you just created. Screen shot can be found [here](https://github.com/portworx/px-docs/blob/gh-pages/k8s-samples/existing-lighthouse/authtoken.png).  You will have to add the logging url to each of your existing nodes `/etc/pwx/config.json`

```
    "loggingurl": "<your-lighthouse-url>/api/stats/listen?token=<Auth-Token>",
```

example configuration line:

```
    "loggingurl": "http://70.0.38.38:30062/api/stats/listen?token-97b7656a-7c86-11e7-a014-428db0678bce",
```    
Step 4: You will need to restart the portworx container for the changes to take affect. Once restarted in Lighthouse under nodes you should see the servers start to populate

Step 5: Add API server and Token fileds and create a new px-spec.yaml file for future servers

```
curl -o px-spec.yaml \
  "https://install.portworx.com?c=mycluster&k=etcd://70.0.38.38:2379&t=token-97b7656a-7c86-11e7-a014-428db0678bce&e=API_SERVER=http://70.0.38.38:30062"
```

>**Note:**<br/> You can also use the HTML form at [install.portworx.com](https://install.portworx.com), and enter at minimum the _<U>c</U>luster name_, _<U>k</U>ey/value database_, _<U>t</U>oken_, and _<U>e</U>nvironment (API\_SERVER=xxx)_ fields.


Step 5b: Or you can edit your existing `px-spec.yaml` file and add the `"-t", "<token>"` and `"env:API_SERVER"` fields, ie:

```
      containers:
        - name: portworx
          image: portworx/px-enterprise:1.2.9
          terminationMessagePath: "/tmp/px-termination-log"
          imagePullPolicy: Always
          args:
             ["-k etcd://70.0.38.38:2379",
              "-c mycluster",
              "-a", "-f",
              "-t", "token-97b7656a-7c86-11e7-a014-428db0678bce",
              "-x", "kubernetes"]
          env:
           - name: API_SERVER
             value: http://70.0.38.38:30062
```             

Step 6: Update the daemonset so new pods will automatically use your lighthouse server

```
kubectl update -f px-spec.yaml            
```

Step 7: Verify the daemonset has been updated.  You should see the `-t <token>` and the `API_SERVER` fields populated

```
kubectl describe daemonset portworx -n kube-system
```

example output:

```
Pod Template:
  Labels:		name=portworx
  Service Account:	px-account
  Containers:
   portworx:
    Image:	portworx/px-enterprise:1.2.9
    Port:	<none>
    Args:
      -k etcd://70.0.38.38:2379
      -c mycluster
      -a -f
      -t token-97b7656a-7c86-11e7-a014-428db0678bce
      -x
      kubernetes
    Liveness:	http-get http://127.0.0.1:9001/status delay=840s timeout=1s period=10s #success=1 #failure=3
    Readiness:	http-get http://127.0.0.1:9001/status delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      API_SERVER:	http://70.0.38.38:30062
```
