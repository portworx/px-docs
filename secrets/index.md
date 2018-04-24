---
layout: page
title: "Setup Secrets Provider"
keywords: portworx, secrets, Kubernetes, vault, encryption, docker, DCOS, KMS
meta-description: "Portworx can integrate with various secrets providers to store your keys/secrets. This guide will get help you configure various providers with Portworx."
---

Portworx can integrate with an external secrets provider to store your credentials and encryption keys. Once integrated with the secrets provider, Portworx can use these secrets to authenticate with cloud providers, encrypt your volumes, etc.

Currently Portworx supports following secrets providers:
1. [Vault](/secrets/portworx-with-vault.html)
2. [AWS KMS](/secrets/portworx-with-aws-kms.html)
3. [Kubernetes Secrets](/secrets/portworx-with-kubernetes-secrets.html)
4. [DC/OS Secrets](/secrets/portworx-with-dcos-secrets.html)
