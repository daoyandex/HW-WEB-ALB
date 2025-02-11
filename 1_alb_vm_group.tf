##########################################################################################
##  Группа ВМ
resource "yandex_compute_instance_group" "alb-vm-group" {
  name                = "alb-vm-group"
  folder_id           = var.yc_folder_id
  service_account_id  = var.sa_web_alb_id
  deletion_protection = false
  
  instance_template {
    name = "web-vm-{instance.index}"
    hostname = "web-vm-{instance.index}"
    platform_id = "standard-v3" 
    resources {
		  cores  = 2
		  core_fraction = 20
		  memory = 2
	  }
    scheduling_policy {
		 preemptible = true
	  }
    boot_disk {
		  mode = "READ_WRITE"
      initialize_params {
			  image_id = var.boot_disk_image_debian_12
			  type = "network-hdd"
			  size = 7
		  }
	  }
    network_interface {
      network_id = yandex_vpc_network.alb-network.id
      subnet_ids = ["${yandex_vpc_subnet.alb-subnet-b.id}", "${yandex_vpc_subnet.alb-subnet-d.id}"]
      security_group_ids = ["${yandex_vpc_security_group.alb-vm-sg.id}"]
    #  nat = true
    }
    
    metadata = { 
      ssh-keys = "${var.vm_user}:${file("${var.ssh_key_path}")}"
      user-data  = "${file("./web-vm-bootstrap/metadata.yaml")}" 
    }
  }
  
  scale_policy {
    fixed_scale {
      size = var.web_cluster_size
    }
  }
  allocation_policy {
    zones = ["ru-central1-b", "ru-central1-d"]
  }
  deploy_policy {
    max_unavailable = 1
    max_creating    = 2
    max_expansion   = 0
    max_deleting    = 2
  }

  application_load_balancer {
    target_group_name = "alb-tg"
  }
}
##########################################################################################

##########################################################################################
# Целевую группу Application Load Balancer нужно привязать к группе бэкендов,
# а группу бэкендов — к балансировщику, напрямую или через HTTP-роутер, в зависимости от типа балансировки. 
# Подробнее см. в инструкциях по управлению ресурсами Application Load Balancer.
# https://yandex.cloud/ru/docs/application-load-balancer/operations/

resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"
  http_backend {
    name                   = "backend-1"
    port                   = 80
    #target_group_ids       = [yandex_compute_instance_group.alb-vm-group.application_load_balancer.0.target_group_id]
    target_group_ids       = ["${yandex_compute_instance_group.alb-vm-group.application_load_balancer.0.target_group_id}"]
    
    load_balancing_config {
      panic_threshold = 50
      mode = "ROUND_ROBIN"
    } 
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

##########################################################################################
# роутер 
resource "yandex_alb_http_router" "alb-router" {
  name   = "alb-router"
}

##########################################################################################
# виртуальный хост, который принадлежит роутеру, и добавляет роутеру конкретные маршруты
resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
#  authority      = [var.domain, "www.${var.domain}"]
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
      }
    }
  }
}

##########################################################################################
# Балансировщик
resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.alb-network.id
  security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.alb-subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.alb-subnet-b.id
    }

    location {
      zone_id   = "ru-central1-d"
      subnet_id = yandex_vpc_subnet.alb-subnet-d.id
    }
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}
##########################################################################################

