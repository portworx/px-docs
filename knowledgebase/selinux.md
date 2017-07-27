---
layout: page
title: "PX with SELinux"
keywords: portworx, troubleshooting, logs, issue
sidebar: home_sidebar
redirect_from: "/selinux.html"
meta-description: “Are you getting a “No such file or directory” message when you use SELinux? Portworx has a solution to resolve the issue.”
---

## "No such file or directory" message when running on SELinux

If you have `SELinux` enabled, you may get the following error message:
 
```
# docker run --name mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw  \
		--volume-driver=pxd -v sql_vol:/var/lib/mysql -d mysql
docker: Error response from daemon: no such file or directory.
See 'docker run --help'.
```

To resolve the issue:

```
# docker run  --security-opt=label:disable --name mysql \
	-e MYSQL_ROOT_PASSWORD=my-secret-pw --volume-driver=pxd -v sql_vol:/var/lib/mysql -d mysql
```

You will not need to workaround this after [20834](https://github.com/docker/docker/pull/20834) is merged.
