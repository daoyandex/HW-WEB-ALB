locals {
  vm_idx = [
    for i in range(0,var.web_cluster_size) : i  
  ]
} 
##########################################################################################
# для 6_snapshots.tf
#data "yandex_compute_instance" "web-vm-instances" {
#  for_each = toset(yandex_compute_instance_group.alb-vm-group.instances.*.instance_id)
#  instance_id = each.value
#  depends_on = [
#    yandex_compute_instance_group.alb-vm-group
#  ]
#}

data "yandex_compute_instance_group" "alb_vm_group_curr" {
  instance_group_id = yandex_compute_instance_group.alb-vm-group.id
}
data "yandex_compute_instance" "web-vm-instances" {
  for_each = tomap ({
    for vm_id, vm_idx in local.vm_idx: vm_id => data.yandex_compute_instance_group.alb_vm_group_curr.instances[vm_idx].instance_id
  })
  
  instance_id = each.value
  
#  depends_on = [
#    yandex_compute_instance_group.alb-vm-group
#  ]
}
##########################################################################################

##########################################################################################
resource "yandex_compute_snapshot_schedule" "alb-group-snapshots-schedule" {
  name           = "alb-group-snapshots-schedule"

  schedule_policy {
    expression = "30 1 ? * *"
  }
  retention_period = "168h0m0s"

  snapshot_spec {
      description = "alb-group-snapshots"
      labels = {
        snapshot-label = "alb-group-snapshots"
      }
  }

  labels = {
    my-label = "alb-group-snapshots-schedule"
  }

  disk_ids = concat(
    [for instance in data.yandex_compute_instance.web-vm-instances : instance.boot_disk[0].disk_id]
    , [yandex_compute_instance.bastion-host.boot_disk[0].disk_id]
    , [yandex_compute_instance.elasticsearch-server.boot_disk[0].disk_id]
    , [yandex_compute_instance.kibana-server.boot_disk[0].disk_id]
    , [yandex_compute_instance.zabbix-server.boot_disk[0].disk_id]
  )

  depends_on = [
    yandex_compute_instance_group.alb-vm-group
  ]
}
##########################################################################################