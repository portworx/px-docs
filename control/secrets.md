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
