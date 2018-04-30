---
layout: page
title: "Lighthouse Create Credentials"
keywords: lighthouse
sidebar: home_sidebar
meta-description: "Create Credentials lighthouse."
---

## Click on Manage Credentails

In the snapshots tab , click on the cloud icon on the right side pane. 

![Lighthouse snapshot tab](/images/lighthouse-new-manage-credentials-1.png){:width="1796px" height="600px"}

## Create New Cloud Credentials

Click `New` button on the Manage Credentials page.Three cloud providers are supported [Azure , Google , Amazon S3].
Newly created credentials will be validated before creation.

`Note` You can create multiple credentials with the same set of details , each credential will generate a unique UUID

![Lighthouse new credentials](/images/lighthouse-new-create-new-credentials-1.png){:width="1796px" height="600px"}


## Azure Credentials

Provide the `Account Name` and `Account Key` to create credentals.
![Lighthouse group snapshot](/images/lighthouse-new-azure-credentials.png){:width="1796px" height="600px"}

## S3 Credentials

Provide the `Access Key` ,  `Secret Key` , `Region` and `Endpoint`to create S3 credentials.

`Note` You can only create credentials using only one Region per cluster.
`Endpoint` value is of type `s3.<region-name>.amazonaws.com`

![Lighthouse group snapshot](/images/lighthouse-new-s3-credentials.png){:width="1796px" height="600px"}

## Google Credentials

Provide the `Project ID ` and `JSON Key file ` to create credentals.
![Lighthouse group snapshot](/images/lighthouse-new-google-credentials.png){:width="1796px" height="600px"}
