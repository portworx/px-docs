---
layout: page
title: "CLI Reference–Secrets"
keywords: portworx, pxctl, command-line tool, cli, reference, secrets, aws, vault, kms, kubernetes, password, login
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
meta-description: "Explore the CLI reference guide for storing secrets for cloudsnaps and encryption. Try it today!"
---

* TOC
{:toc}

The `pxctl secrets` command helps the user store the secrets in different kinds of secrets store and help manage the secrets and access keys in a secure, production-ready manner. 

```
/opt/pwx/bin/pxctl secrets -h
NAME:
  pxctl secrets - Manage Secrets

USAGE:
  pxctl secrets command [command options] [arguments...]

COMMANDS:
    set-cluster-key, sc  Set cluster key to be used for encryption
    vault                Vault secret-endpoint commands
    aws                  AWS secret-endpoint commands
    kvdb                 kvdb secret-endpoint commands
    docker               Docker Secret commands
    k8s                  Kubernetes Secret commands

OPTIONS:
  --help, -h  show help
```

Following are the examples of some of the usages. Please refer to the `pxctl credentials` page for a more comprehensive discussion on how to use credentials and secrets together.

For AWS, the usage is as follows:

```
# pxctl secrets aws login
Enter AWS_ACCESS_KEY_ID [Hit Enter to ignore]: ********************
Enter AWS_SECRET_ACCESS_KEY [Hit Enter to ignore]: ****************************************
Enter AWS_SECRET_TOKEN_KEY [Hit Enter to ignore]:
Enter AWS_CMK [Hit Enter to ignore]: ***********************
Enter AWS_REGION [Hit Enter to ignore]: us-east-1
Successfully authenticated with AWS.
```
