##########################################################################################
## инициализация провайдера
terraform {
	required_providers {
		yandex = {
			source = "yandex-cloud/yandex"
		}
	}
}
provider "yandex" {
	#token     = "${YC_TOKEN}" # var.yc_iam_token
    #cloud_id  = var.yc_cloud_id
    #folder_id = var.yc_folder_id
    #zone      = var.region
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
## 2. NAT-gateway
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "internet-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
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
  #ingress {
  #  description    = "ANY"
	#  protocol       = "ANY"
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 0
  #  to_port        = 65535 # порт, по которому придет запрос
  #}

}
##########################################################################################

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

  # рабочие порты балансировщика
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

  # + к заблокированию.
  #ingress {
  #  description    = "ANY"
	#  protocol       = "ANY"
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 0
  #  to_port        = 65535 # порт, по которому придет запрос
  #}
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
  
  # взаимодействие с bastion-host
  ingress {
    description    = "bastion"
	  protocol       = "TCP"
    port = 22 # порт, по которому придет запрос от бастионного хоста
    #from_port      = 0
    #to_port        = 65535
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }

  # запросы извне
  ingress {
    description    = "HTTP requests"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    from_port      = 80 #0
    to_port        = 80 #65535 # порт, по которому придет запрос
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
  # --

  # взаимодействие с bastion-host
  ingress {
    description    = "bastion"
	  protocol       = "TCP"
    port = 22 # порт, по которому придет запрос от бастионного хоста
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }
  
  # взаимодействие с alb-balancer
  ingress {
    description    = "balancer"
	  protocol       = "TCP"
    port = 80 # порт, по которому придет запрос от Балансировщика "alb-1" --- means any port
    security_group_id = yandex_vpc_security_group.alb-sg.id  # адрес откуда идет запрос
  }

  # взаимодействие с Zabbix-сервером
  ingress {
    description    = "zabbix-server"
	  protocol       = "TCP"
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
    security_group_id = yandex_vpc_security_group.zabbix-sg.id  # адрес откуда идет запрос
  }

  ## + к заблокированию. пока нужен для тестирования работы nginx через браузер
  #ingress {
  #  description    = "HTTP requests"
	#  protocol       = "TCP" #ANY
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 80 #0
  #  to_port        = 80 #65535 порт, по которому придет запрос
  #}
  
  ## + к заблокированию. пока нужен для тестирования работы через ssh
  #ingress {
  #  description    = "ANY"
	#  protocol       = "ANY"
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 0
  #  to_port        = 65535 # порт, по которому придет запрос
  #}
}
##########################################################################################

##########################################################################################
## 5. Группа безопасности для группы ВМ 
resource "yandex_vpc_security_group" "kibana-sg" {
  description = "Security group for kibana-server. On public segment, but public access is on the port 80 only. External administration through bastion-host only."
  name        = "kibana-sg"
  network_id  = "${yandex_vpc_network.alb-network.id}"

  labels = {
    alb-vm-sg-label = "kibana-sg-label"
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
    #from_port      = 0
    #to_port        = 65535 # порт, по которому придет запрос
    security_group_id = yandex_vpc_security_group.bastion-sg.id  # адрес откуда идет запрос
  }
  
  # взаимодействие с filebeat
  ingress {
    description    = "filebeat"
	  protocol       = "ANY"
    from_port      = 0
    to_port        = 65535 # порт, по которому придет запрос
    security_group_id = yandex_vpc_security_group.alb-vm-sg.id  # адрес откуда идет запрос
  }

  # запросы 
  ingress {
    description    = "public interface 5601"
	  protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 5601
  }

  # + на вход (для теста при nat=true) - к заблокированию
  #ingress {
  #  description    = "HTTP requests"
	#  protocol       = "TCP" #ANY
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  port = 80
  #}
  
  ## + к заблокированию. пока нужен для тестирования работы nginx
  #ingress {
  #  description    = "ANY"
	#  protocol       = "ANY"
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 0
  #  to_port        = 65535 # порт, по которому придет запрос
  #}
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
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    security_group_id = yandex_vpc_security_group.kibana-sg.id  # адрес откуда идет запрос
  }

    # взаимодействие с группой web-vm
  ingress {
    description    = "filebeat"
	  protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    security_group_id = yandex_vpc_security_group.alb-vm-sg.id  # адрес откуда идет запрос
  }
  
  ## + всё на вход (для теста при nat=true) - к заблокированию
  #ingress {
  #  description    = "ANY"
	#  protocol       = "ANY"
  #  v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
  #  from_port      = 0
  #  to_port        = 65535 # порт, по которому придет запрос
  #}
}
##########################################################################################

