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
  
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port = 80
    #from_port      = 0
    #to_port        = 65535 # порт, по которому придет запрос
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