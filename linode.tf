provider "linode" {
    token = var.token
}

locals {
  create_time = "${formatdate("hh_mm_ss", timestamp())}"
}

resource "linode_instance" "rancher_docker" {
  count = var.node_count
  image = "linode/ubuntu19.04"
  label = "${var.label}_instance_${local.create_time}_${count.index}"
  region = "us-central"
  type = "g6-standard-1" # https://cloud.linode.com/api/v4/linode/types
  authorized_keys = [var.ssh_key]
  root_pass = var.root_pass

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      timeout  = "2m"
      host     = self.ip_address
      user     = "root"
      agent    = "true"
      password = var.root_pass
      # private_key = var.ssh_key
    }
    inline = [
      "export PATH=$PATH:/usr/bin",
      "apt-get update -y",
      "apt-get remove docker docker-engine docker.io -y",
      "apt install docker.io -y",
      "systemctl start docker",
      "systemctl enable docker",
      "docker --version",
      "sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher",
    ]
  }
}

variable token {}
variable root_pass {}
variable ssh_key {}
variable node_count {}
variable label {}
