##########################################################################################
# web-vm 's internal ip
data "yandex_compute_instance_group" "alb_vm_group" {
  instance_group_id = yandex_compute_instance_group.alb-vm-group.id
}
output "vm-ips" {
    value = tomap ({
    for nat_ip_address, vm in data.yandex_compute_instance_group.alb_vm_group.instances : nat_ip_address => vm.network_interface.0.nat_ip_address
  })
}
##########################################################################################

##########################################################################################
output "alb-1-listener" {
  value = yandex_alb_load_balancer.alb-1.listener
}
##########################################################################################

##########################################################################################
data "yandex_compute_instance" "zabbix-server" {
  instance_id = yandex_compute_instance.zabbix-server.id
}
output "zabbix-vm-nat-ip-address" {
  value = "${data.yandex_compute_instance.zabbix-server.network_interface.0.nat_ip_address}"
#  value = yandex_compute_instance.vm-tf-1.network_interface.0.nat_ip_address
}
##########################################################################################

##########################################################################################
data "yandex_compute_instance" "kibana-server" {
  instance_id = yandex_compute_instance.kibana-server.id
}
output "kibana-server-nat-ip-address" {
  value = "${data.yandex_compute_instance.kibana-server.network_interface.0.nat_ip_address}"
}
##########################################################################################

##########################################################################################
output "bastion-host-ip" {
  value = yandex_compute_instance.bastion-host.network_interface.0.ip_address
}
output "bastion-host-nat-ip" {
  value = yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address
}
##########################################################################################