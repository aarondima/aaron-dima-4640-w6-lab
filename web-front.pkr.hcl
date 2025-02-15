# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      # COMPLETE ME complete the "name" argument below to use Ubuntu 24.04
      name                = "*-24.04-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.ubuntu"
  ]

  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # COMPLETE ME add inline scripts to create necessary directories and change directory ownership.
      "sudo mkdir -p /tmp/web",
      "sudo chown -R ubuntu:ubuntu /tmp/web",
      "sudo mkdir -p /web/html",
      "sudo chown -R ubuntu:ubuntu /web/html"
    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source      = "./files/index.html"
    destination = "/tmp/web/index.html"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source      = "./files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks
  provisioner "file" {
    source      = "./scripts/install-nginx"
    destination = "/tmp/install-nginx"
  }
  provisioner "file" {
    source      = "./scripts/setup-nginx"
    destination = "/tmp/setup-nginx"
  }
  provisioner "shell" {
    inline = [
      "sudo chmod u+x /tmp/install-nginx",
      "sudo /tmp/install-nginx",
      "sudo chmod u+x /tmp/setup-nginx",
      "sudo /tmp/setup-nginx",
      "sudo systemctl reload nginx"
    ]
  }


}
