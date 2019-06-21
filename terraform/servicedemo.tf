# PROVIDER
provider "digitalocean" {
    token = "${var.do_token}"
}


# SERVICE PROJECT
resource "digitalocean_project" "service-demo" {
  name        = "Service demo"
  description = "Service-demo infrastructure"
  purpose     = "Service or API"
  environment = "Development"
  resources   = [
    "${digitalocean_droplet.service-server-1.urn}",
    "${digitalocean_droplet.service-server-2.urn}",
    "${digitalocean_loadbalancer.service-loadbalancer.urn}",
    "${digitalocean_droplet.service-database.urn}"
  ]
}


# TEMPLATES
data "template_file" "service_server_setup" {
  template = "${file("${path.module}/scripts/service_server_setup.sh.tpl")}"
}
data "template_file" "service_server_apprun" {
  template = "${file("${path.module}/scripts/service_server_apprun.sh.tpl")}"
  vars {
    DB_IP = "${digitalocean_droplet.service-database.ipv4_address}"
  }
}
data "template_file" "service_database_setup" {
  template = "${file("${path.module}/scripts/service_database_setup.sh.tpl")}"
}


# SERVICE LOADBALANCER
resource "digitalocean_loadbalancer" "service-loadbalancer" {
  name = "service-loadbalancer"
  region = "${var.service_region}"
  algorithm = "least_connections"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 5000
    target_protocol = "http"
  }

  healthcheck {
    port = 5000
    protocol = "tcp"
  }

  droplet_ids = [
    "${digitalocean_droplet.service-server-1.id}",
    "${digitalocean_droplet.service-server-2.id}"
  ]
}


# MYSQL DB
resource "digitalocean_droplet" "service-database" {
  image = "${var.service_database_image}"
  name = "service-database"
  region = "${var.service_region}"
  size = "${var.service_database_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_database_setup.rendered}"]
  }
}


# SERVICE SERVERS
resource "digitalocean_droplet" "service-server-1" {
  image = "${var.service_server_image}"
  name = "service-server-1"
  region = "${var.service_region}"
  size = "${var.service_server_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_setup.rendered}"]
  }
  provisioner "file" {
    source      = "../"
    destination = "/etc/service"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_apprun.rendered}"]
  }
}

resource "digitalocean_droplet" "service-server-2" {
  image = "${var.service_server_image}"
  name = "service-server-2"
  region = "${var.service_region}"
  size = "${var.service_server_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_setup.rendered}"]
  }
  provisioner "file" {
    source      = "../"
    destination = "/etc/service"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_apprun.rendered}"]
  }
}
