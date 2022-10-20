# chromium-webview Packer AMI builder

## What is this?

This is a [Packer](https://www.packer.io/) configuration to create an Ubuntu VM image on AWS pre-seeded with the appropriate dependencies and source for building chromium-webview.

## How to use it

Before creating an AMI, ensure your AWS credentials are configured in `~/.aws/credentials`.

### Creating a new AMI

`packer build chromium-webview.pkr.hcl`

This will create an instance in AWS with a base AMI (Ubuntu in this case) and run any provisioners in the `chromium-webview.pkr.hcl` file while streaming the output to the console. Once this is done, the instance will be stopped, a snapshot created, and an AMI from the snapshot. The AMI ID will be printed in the console. The Terraform configuration does not need the direct AMI, and will instead query for the appropriate latest build.
