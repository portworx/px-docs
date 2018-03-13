As Portworx needs to create and attach EBS volumes, it needs corresponding AWS permissions. Following is a sample policy describing those permissions:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "<stmt-id>",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeTags",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

You can provide these permissions to Portworx in one of following ways:

1. Instance Privileges: Provide above permissions for all the instances in the autoscaling cluster by applying the corresponding IAM role. More info about IAM roles and policies can be found [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
2. Environment Variables: Create a User with the above policy and provide the security credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) to Portworx.
