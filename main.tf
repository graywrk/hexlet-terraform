terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "web-1" {
  name = var.server_name_1

  resources {
    cores = var.num_cpu
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.bootdisk_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat = var.enable_nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "web-2" {
  name = var.server_name_2

  resources {
    cores = var.num_cpu
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.bootdisk_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet1"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = var.subnet_v4_cidr_blocks
}

output "internal_ip_address_web_1" {
  value = yandex_compute_instance.web-1.network_interface.0.ip_address
}

output "internal_ip_address_web_2" {
  value = yandex_compute_instance.web-2.network_interface.0.ip_address
}

output "external_ip_address_web_1" {
  value = yandex_compute_instance.web-1.network_interface.0.nat_ip_address
}

output "external_ip_address_web_2" {
  value = yandex_compute_instance.web-2.network_interface.0.nat_ip_address
}