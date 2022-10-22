packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "chromium-webview-cr11-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_type = "c5ad.16xlarge"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

  aws_polling {
    delay_seconds = 60
    max_attempts  = 120
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "io2"
    iops                  = 30000
    delete_on_termination = true
  }

  ena_support             = true
  ami_virtualization_type = "hvm"
}

build {
  name = "chromium-webview-cr11"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBCONF_NONINTERACTIVE_SEEN=true",
    ]
    inline = [
      "set -xe",
      "sleep 30",
      "sudo apt-get -y -o DPkg::Lock::Timeout=300 update",
      "sudo apt-get -y -o DPkg::Lock::Timeout=300 upgrade",
      "sudo apt-get -y -o DPkg::Lock::Timeout=300 install --no-install-recommends git awscli jq curl fpart",
      "git config --global user.name 'CarbonROM Webview CI Bot'",
      "git config --global user.email 'carbonrom_webview_ci_bot@mcswain.dev'",
      "git config --global pack.threads '0'",
      "git config --global pack.windowMemory '1300m'",
      "sudo mkfs.ext4 -F /dev/nvme1n1",
      "sudo mkdir -p /mnt/src",
      "sudo mount /dev/nvme1n1 /mnt/src",
      "sudo chmod 777 /mnt/src",
      "git clone --progress https://github.com/CarbonROM/android_external_chromium-webview.git -b cr-11.0 /mnt/src/chromium-webview",
      "cd /mnt/src/chromium-webview && ./build-webview.sh -s -b",
      "echo \"Size is `du -sh /mnt/src/chromium-webview | awk '{ print $1 }'`\"",
      "sync"
    ]
  }
}
