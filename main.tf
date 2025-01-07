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



