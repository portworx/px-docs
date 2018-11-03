This guide will give you an overview of how to use Encryption feature for Portworx volumes.
Under the hood Portworx uses libgcrypt library to interface with the dm-crypt module for creating, accessing and managing encrypted devices. Portworx uses the LUKS format of dm-crypt and AES-256 as the cipher with xts-plain64 as the cipher mode.

Portworx has two different kinds of encrypted volumes

- **Encrypted Volumes**

Encrypted volumes are regular volumes which can be accessed from only one node.

- **Encrypted Shared Volumes**

Encrypted shared volume allows access to the same encrypted volume from multiple nodes.

All the encrypted volumes are protected by a passphrase. Portworx uses the passphrase to encrypt/decrypt the volumes. It is recommended to store these passphrases in a secure secret store. To know more about the supported secret providers and how to configure them with Portworx, refer to the [Setup Secrets Provider](/secrets) guide.
