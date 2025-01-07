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
    port = -1 # порт, по которому придет запрос  --- means any port
  }
  # --

  ingress {
    description    = "balancer"
	  protocol       = "TCP"
    port = 80 # порт, по которому придет запрос от Балансировщика "alb-1" --- means any port
    security_group_id = yandex_vpc_security_group.alb-sg.id  # адрес откуда идет запрос
  }

  ingress {
    description    = "ssh"
	  protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port           = 22 # порт, по которому придет запрос
  }
  
  # ++
  ingress {
    description    = "ANY"
	  protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]  # адрес откуда идет запрос --- м.б. любым
    port           = -1 # порт, по которому придет запрос
  }
  # --
}
##########################################################################################