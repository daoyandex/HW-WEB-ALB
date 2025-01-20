##########################################################################################
# Отказоустойчивый сайт с балансировкой нагрузки с помощью Yandex Application Load Balancer
#
# https://yandex.cloud/ru/docs/application-load-balancer/tutorials/application-load-balancer-website#console_3
#
##########################################################################################

##########################################################################################
resource "yandex_compute_image" "lemp" {
  source_family = "lemp"
}

##########################################################################################

##########################################################################################
## 2. NAT-gateway
resource "yandex_vpc_gateway" "nat-gateway" {
  name = "internet-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route-table" {
  folder_id  = var.yc_folder_id
  name       = "route-table"
  network_id = yandex_vpc_network.alb-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  #  next_hop_address   = yandex_compute_instance.bastion-vm.network_interface.0.ip_address
  }
}
##########################################################################################

##########################################################################################
## 1 Сеть и подсети для Балансировщика и ВМ-web-servers
resource "yandex_vpc_network" "alb-network" {
	name = "alb-network"
}

### 1.1.Подсеть а 
resource "yandex_vpc_subnet" "alb-subnet-a" {
	name = "alb-subnet-a"
	zone = "ru-central1-a"
	v4_cidr_blocks = ["172.16.10.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
### 1.2.Подсеть b
resource "yandex_vpc_subnet" "alb-subnet-b" {
	name = "alb-subnet-b"
	zone = "ru-central1-b"
	v4_cidr_blocks = ["172.16.20.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
### 1.3.Подсеть d
resource "yandex_vpc_subnet" "alb-subnet-d" {
	name = "alb-subnet-d"
	zone = "ru-central1-d"
	v4_cidr_blocks = ["172.16.30.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
##########################################################################################

##########################################################################################
## 1. Группа безопасности для Бастионного хоста
resource "yandex_vpc_security_group" "bastion-sg" {
  description = "Security group for bastion host"
  name        = "bastion-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"
  
  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535
  }
  
  ingress {
    description    = "ssh"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port           = 22 # порт, по которому придет запрос
  }

  # + этот блок к заблокированию
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }

}
##########################################################################################
## 2. Группа безопасности для Балансировщика 
resource "yandex_vpc_security_group" "alb-sg" {
  description = "ALB security group for ALB"
  name        = "alb-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"

  labels = {
    alb-sg-label = "alb-sg-label"
  }

  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
  
  ingress {
    description    = "ext-http"
	  protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port           = 80 # порт, по которому придет запрос
  }
  ingress {
    description    = "ext-https"
	  protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port           = 443 # порт, по которому придет запрос
  }
  ingress {
    description    = "healthchecks"
	  protocol       = "TCP"
    predefined_target = "loadbalancer_healthchecks"  # проверка балансировщиком состояния ВМ
    port           = 30080 # порт, по которому придет запрос
  }
}
##########################################################################################

##########################################################################################
## 3. Группа безопасности для группы ВМ 
resource "yandex_vpc_security_group" "alb-vm-sg" {
  description = "ALB security group for web-servers"
  name        = "alb-vm-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"

  labels = {
    alb-vm-sg-label = "alb-vm-sg-label"
  }

  # ++
  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
 
  # взаимодействие с alb-balancer
  ingress {
    description    = "balancer"
	  protocol       = "TCP"
    port = 80 # порт, по которому придет запрос от Балансировщика "alb-1" --- means any port
    security_group_id = yandex_vpc_security_group.alb-sg.id  # адрес откуда идет запрос
  }
  
  # взаимодействие с bastion-host
  ingress {
    description    = "bastion"
	  protocol       = "TCP"
    port = 22 # порт, по которому придет запрос от бастионного хоста
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }
  
  # взаимодействие с Zabbix-сервером
  ingress {
    description    = "Zabbix"
	  protocol       = "TCP"
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
    security_group_id = yandex_vpc_security_group.zabbix-sg.id  # адрес откуда идет запрос
  }

  # взаимодействие с Elasticsearch-сервером
  ingress {
    description    = "elasticsearch"
	  protocol       = "TCP"
    #from_port      = 0
    #to_port        = 65535 # порт, по которому придет запрос
    port           = 9200
    security_group_id = yandex_vpc_security_group.elasticsearch-sg.id  # адрес откуда идет запрос
  }

  # + всё на вход - к заблокированию
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
  # - всё на вход - к заблокированию
}
##########################################################################################

##########################################################################################
## 4. Группа безопасности для Zabbix-хоста
resource "yandex_vpc_security_group" "zabbix-sg" {
  description = "Security group for zabbix host"
  name        = "zabbix-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"
  
  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535
  }
  
  # запросы внешних пользователей
  ingress {
    description    = "public interface"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port = 80 
  }

  # + этот блок к заблокированию
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
  # - этот блок к заблокировани
}
##########################################################################################

##########################################################################################
## 5. Группа безопасности для группы ВМ 
resource "yandex_vpc_security_group" "kibana-sg" {
  description = "Security group for kibana-server. On public segment, but public access is on the port 80 only. External administration through bastion-host only."
  name        = "kibana-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"

  labels = {
    alb-vm-sg-label = "elasticsearch-sg-label"
  }

  # ++ правило для исходящего трафика
  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }

  # взаимодействие с bastion-host
  ingress {
    description    = "bastion"
	  protocol       = "TCP"
    port = 22 # порт, по которому придет запрос от бастионного хоста
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }
  
  # запросы внешних пользователей
  ingress {
    description    = "public interface 80"
	  protocol       = "TCP"
    port = 80 # порт, по которому придет запрос от бастионного хоста
  }
  
  # запросы внешних пользователей
  ingress {
    description    = "public interface 5601"
	  protocol       = "TCP"
    port = 5601 # порт, по которому придет запрос от бастионного хоста
  }

  # + всё на вход (для теста при nat=true) - к заблокированию
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
}
##########################################################################################

##########################################################################################
## 6. Группа безопасности для группы ВМ 
resource "yandex_vpc_security_group" "elasticsearch-sg" {
  description = "Security group for elasticsearch-server. On private segment. AExternal administration through bastion-host only."
  name        = "elasticsearch-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"

  labels = {
    alb-vm-sg-label = "elasticsearch-sg-label"
  }

  # ++ правило для исходящего трафика
  egress {
    description    = "ANY egress rule description"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }

  # взаимодействие с bastion-host
  ingress {
    description    = "bastion"
	  protocol       = "TCP"
    port = 22 # порт, по которому придет запрос от бастионного хоста
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }

  # взаимодействие с kibana-server
  ingress {
    description    = "kibana"
	  protocol       = "TCP"
    #port = 22 # порт, по которому придет запрос от бастионного хоста
    from_port      = 0
    to_port        = 65535
    security_group_id = yandex_vpc_security_group.kibana-sg.id  # адрес откуда идет запрос
  }
  
  # + всё на вход (для теста при nat=true) - к заблокированию
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
  }
}
##########################################################################################


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
		  memory = 1
	  }
    scheduling_policy {
		 preemptible = true
	  }
    boot_disk {
		  mode = "READ_WRITE"
      initialize_params {
			  image_id = var.boot_disk_image_debian_12
			  type = "network-hdd"
			  size = 3
		  }
	  }
    network_interface {
      network_id = yandex_vpc_network.alb-network.id
      subnet_ids = ["${yandex_vpc_subnet.alb-subnet-b.id}", "${yandex_vpc_subnet.alb-subnet-d.id}"]
      security_group_ids = ["${yandex_vpc_security_group.alb-vm-sg.id}"]
      nat = true
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

