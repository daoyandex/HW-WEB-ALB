variable "sa_web_alb_id" {
  type = string
  description = "Данная переменная потребует ввести domain в консоли при запуске terraform plan/apply"
}

variable "vm_user" {
  type = string
  description = "Данная переменная потребует ввести domain в консоли при запуске terraform plan/apply"
}

variable "ssh_key_path" {
  type = string
  description = "Данная переменная потребует ввести domain в консоли при запуске terraform plan/apply"
}

variable "domain" {
  type = string
  description = "Данная переменная потребует ввести domain в консоли при запуске terraform plan/apply"
}

variable "web_cluster_size" {
  type = number
  description = "Данная переменная потребует ввести web_cluster_size в консоли при запуске terraform plan/apply"
}

# folder_id = "b1g0p7hjk9b1452669ri" # export TF_VAR_folder_id=$(yc config get folder-id)
variable "yc_folder_id" {
  type = string
  description = "Данная переменная потребует ввести folder_id в консоли при запуске terraform plan/apply"
}

variable "boot_disk_image_id" {
  description = "Type id for Boot disk image (lets gess)"
  default = "fd870suu28d40fqp8srr" #"fd87kbts7j40q5b9rpjr"
}

variable "main_zone" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = "ru-central1-a"
}

variable "zones" {
  type    = list(string)
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}