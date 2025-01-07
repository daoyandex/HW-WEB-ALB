
##########################################################################################
## 1 Сеть и подсети для Балансировщика и ВМ-web-servers
resource "yandex_vpc_network" "alb-network" {
	name = "alb-network"
}

### 1.1.Подсеть а 
resource "yandex_vpc_subnet" "alb-network-a" {
	name = "alb-network-a"
	zone = "ru-central1-a"
	v4_cidr_blocks = ["172.16.10.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
### 1.2.Подсеть b
resource "yandex_vpc_subnet" "alb-network-b" {
	name = "alb-network-b"
	zone = "ru-central1-b"
	v4_cidr_blocks = ["172.16.20.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
### 1.3.Подсеть d
resource "yandex_vpc_subnet" "alb-network-d" {
	name = "alb-network-d"
	zone = "ru-central1-d"
	v4_cidr_blocks = ["172.16.30.0/24"]
	network_id = yandex_vpc_network.alb-network.id
	route_table_id = yandex_vpc_route_table.rt.id
}
##########################################################################################

