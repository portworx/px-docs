---
layout: page
title: "Deploy 'Portworx-ready' Mesosphere DCOS cluster on AWS"
keywords: portworx, mesos, mesosphere, dcos, aws, cloudformation
sidebar: home_sidebar
---

These instructions are for users wanting to deploy a 'Portworx-ready' cluster in AWS, prior to actually installing Portworx.

The AWS CloudFormation template below differs only slightly from the standard [DCOS Stable](https://downloads.dcos.io/dcos/stable/aws.html) versions,
in that the 'SlaveLaunchConfig' contains an addition 80GB gp2 EBS volume.

<p><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=PX-STACK&amp;templateURL=https://s3.amazonaws.com/px-ready-dcos/px-ready-dcos_1.10_CF.json" rel="nofollow noreferrer" target="_blank"><img src="https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg" alt="Launch Stack" width="144px" height="27px" class="cf-stack"></a></p>
