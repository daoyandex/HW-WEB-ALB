##########################################################################################
output "bastion-host-ip" {
  value = yandex_compute_instance.bastion-host.network_interface.0.ip_address
}
output "bastion-host-nat-ip" {
  value = yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address
}
##########################################################################################

##########################################################################################
output "alb-1-listener" {
  value = yandex_alb_load_balancer.alb-1.listener
}
##########################################################################################

##########################################################################################
data "yandex_compute_instance" "zabbix-server" {
  zabbix_vm_id = yandex_compute_instance.zabbix-server.id
}
output "zabbix-vm-nat-ip-address" {
  value = "${data.zabbix-server.network_interface.0.nat_ip_address}"
}
##########################################################################################

##########################################################################################
data "yandex_compute_instance_group" "alb_vm_group" {
  instance_group_id = yandex_compute_instance_group.alb-vm-group.id
}

output "instances_external_ip" {
  value = "${data.yandex_compute_instance_group.alb_vm_group.instances.*.network_interface.0.nat_ip_address}"
}
output "instances_internal_ip" {
  value = "${data.yandex_compute_instance_group.alb_vm_group.instances.*.network_interface.0.ip_address}"
}
output "instance_hosname" {
  value = "${data.yandex_compute_instance_group.alb_vm_group.instances.*.name}"
}
#output "vm-ips" {
#  value = tomap ({
#    for name, vm in yandex_compute_instance.vm : name => vm.network_interface.0.nat_ip_address
#  })
#}
#output "vm-ip_addresses" {
#  value = tomap ({
#    for name, vm in yandex_compute_instance.vm : name => vm.network_interface.0.ip_address
#  })
#}
##########################################################################################