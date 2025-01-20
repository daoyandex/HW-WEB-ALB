#############################################################################
## Здесь инициализация 2-х ВМ
resource "yandex_compute_instance" "bastion-host" {
    zone = "ru-central1-a"
    name     = "bastion-host"
    hostname = "bastion-host"
    platform_id = "standard-v3"
    allow_stopping_for_update = true

    scheduling_policy {
        preemptible = true
    }

    boot_disk {
        mode = "READ_WRITE"
        initialize_params {
            image_id = yandex_compute_image.lemp.id
            type = "network-hdd"
            size = 3
        }
    }

    resources {
        cores  = 2
        core_fraction = 20
        memory = 1
    }

    network_interface {
        subnet_id = "${yandex_vpc_subnet.alb-subnet-a.id}"
        security_group_ids = ["${yandex_vpc_security_group.bastion-sg.id}"]
        nat = true
    }

    metadata = { 
      ssh-keys = "${var.vm_user}:${file("${var.ssh_key_path}")}"
      user-data  = "${file("./web-vm-bootstrap/user.yaml")}"
    }
}
#############################################################################
