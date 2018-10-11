**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/maintain/etcd.html).

{% if include.skip_firewall != "true"  %}

**Firewall**

Ensure ports 9001-9015 are open between the nodes that will run Portworx. Your nodes should also be able to reach the port KVDB is running on (for example etcd usually runs on port 2379).
{% endif %}

{{ include.firewall-custom-steps }}

{% if include.skip_ntp != "true"  %}
**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
{% endif %}