locals {
  timever = "${legacy_isotime("20060102150405")}"

  ami_tags = {
    base-ami-id     = "{{ .SourceAMI }}"
    base-ami-name   = "{{ .SourceAMIName }}"
    base-ami-region = "{{ .BuildRegion }}"
    base-ami-owner  = "{{ .SourceAMIOwner }}"
    release-date    = local.timever
    managed-by      = "packer"
  }
}

data "amazon-ami" "ubuntu_2204_ami_amd64" {
  filters = {
    name                = "ubuntu-eks/k8s_1.29/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-east-1"
}

source "amazon-ebs" "ubuntu_2204_ami_amd64" {
  ami_org_arns = [
    "arn:aws:organizations::679326928313:organization/o-8eu5opwkl9",
  ]
  ami_regions = [
    "us-east-1",
  ]
  region       = "us-east-1"
  source_ami   = "${data.amazon-ami.ubuntu_2204_ami_amd64.id}"
  ssh_username = "ubuntu"

  iam_instance_profile = "li-packer-builder-instance-profile"

  subnet_filter {
    filters = {
      "tag:Name" : "devops-tooling-private-us-east-1a"
      "tag:Name" : "devops-tooling-private-us-east-1b"
      "tag:Name" : "devops-tooling-private-us-east-1c"
      "tag:Name" : "devops-tooling-private-us-east-1d"
      # "tag:Name" : "devops-tooling-private-us-east-1e" # For some reason we can't create instances in this subnet
      # "tag:Name" : "devops-tooling-private-us-east-1f"
    }
    most_free = true
    random    = true
  }

  # Enables AWS SSM as the SSH agent
  ssh_interface = "private_ip"
  # Why: https://github.com/hashicorp/packer/issues/11733#issuecomment-1106564658
  temporary_key_pair_type = "ed25519"

  #   instance_type = "g6.xlarge"
  instance_type = "g6.xlarge"
}

build {
  source "source.amazon-ebs.ubuntu_2204_ami_amd64" {
    name = "li-eks-129-ubuntu-2004-amd64"

    ami_name = "li-eks-129-ubuntu-2004-amd64-${local.timever}"

    tags = merge(local.ami_tags,
      {
        Name              = "li-eks-129-ubuntu-2004-amd64-${local.timever}"
        os_distro         = "Ubuntu"
        os_distro_version = "20.04"
      }
    )

    run_tags = merge(local.ami_tags,
      {
        Name              = "li-eks-129-ubuntu-2004-amd64-${local.timever}"
        os_distro         = "Ubuntu"
        os_distro_version = "20.04"
      }
    )
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install nvidia-driver-550-server xserver-xorg-video-nvidia-550-server libnvidia-cfg1-550-server mesa-vulkan-drivers",
      # "sudo apt search ubuntu-drivers-common",
      # "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-drivers-common",
      # "sudo ubuntu-drivers install nvidia:550-server",
      "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg   && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |     sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |     sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit",
      "sudo nvidia-ctk runtime configure --runtime=containerd",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo -e '[Unit]\nDescription=Run nvidia-smi at system startup\n\n[Service]\nExecStart=/usr/bin/nvidia-smi\nType=oneshot\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/nvidia-smi.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable nvidia-smi.service",
      "sudo systemctl start nvidia-smi.service",
    ]
  }
}
