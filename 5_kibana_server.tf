##########################################################################################
## Здесь инициализация ВМ для zabbix-server
resource "yandex_compute_instance" "kibana-server" {
    zone = "ru-central1-a"
    name     = "kibana-server"
    hostname = "kibana-server"
    platform_id = "standard-v3"
    allow_stopping_for_update = true

    scheduling_policy {
        preemptible = true
    }

    boot_disk {
        mode = "READ_WRITE"
        initialize_params {
            image_id = var.boot_disk_image_debian_12
            type = "network-hdd"
            size = 10
        }
    }

    resources {
        cores  = 2
        core_fraction = 20
        memory = 2
    }

    network_interface {
        subnet_id = "${yandex_vpc_subnet.alb-subnet-a.id}"
        security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
        nat = true
    }

    metadata = { 
      ssh-keys = "${var.vm_user}:${file("${var.ssh_key_path}")}"
      user-data  = "${file("./web-vm-bootstrap/user.yaml")}"
    }
}
##########################################################################################
