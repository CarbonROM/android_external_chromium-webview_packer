# chromium-webview Packer AMI builder

## What is this?

This is a [Packer](https://www.packer.io/) configuration to create an Ubuntu VM image on AWS pre-seeded with the appropriate dependencies and source for building chromium-webview.

## How to use it

### With CI

This repo contains the appropriate CI configuration to allow the Chromium source to be pre-populated in an AWS AMI image. The synced Chromium version is obtained from the current `HEAD` of the current CarbonROM branch of [CarbonROM/external_chromium-webview](https://github.com/CarbonROM/android_external_chromium-webview) in `build-webview.sh`. Ensure this is up to date on GitHub before attempting to run the Packer build.

Commit any changes and push to Gerrit. After review and submission, return to the GitHub repository and navigate to Actions -> Packer or use this direct link <https://github.com/CarbonROM/android_external_chromium-webview_packer/actions/workflows/packer.yaml>.

There will be a box that says

> This workflow has a `workflow_dispatch` event trigger.

There is a button that says `Run workflow` in the right side of this box. Click it and choose the appropriate Carbon branch, then click the green `Run workflow` button.

A Packer job will be created that will sync the Chromium source and create an AMI image for use in the Chromium Android System Webview CI. There is no need to update the AMI ID anywhere, as the Terraform CI in Chromium Android System Webview will obtain the latest release of this AMI.

### Manually

Before creating an AMI, ensure your AWS credentials are configured in `~/.aws/credentials`.

Then, run `packer build chromium-webview.pkr.hcl`

This will create an instance in AWS with a base AMI (Ubuntu in this case) and run any provisioners in the `chromium-webview.pkr.hcl` file while streaming the output to the console. Once this is done, the instance will be stopped, a snapshot created, and an AMI from the snapshot. The AMI ID will be printed in the console. The Terraform configuration does not need the direct AMI, and will instead query for the appropriate latest build.
