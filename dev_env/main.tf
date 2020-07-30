
# scw instance server create type=DEV1-S zone=fr-par-1 image=ubuntu_bionic root-volume=l:20G  name=dev  ip=new 
# scw instance server create type=DEV1-S zone=fr-par-1 image=ubuntu_focal root-volume=l:20G  name=dev  ip=new 

terraform {
  backend "local" {
    path = "/tfstate/terraform.tfstate"
  }
}

# https://www.terraform.io/docs/providers/scaleway/index.html
provider "scaleway" {
#  access_key      = "<SCALEWAY-ACCESS-KEY>"
#  secret_key      = "<SCALEWAY-SECRET-KEY>"
#  organization_id = "<SCALEWAY-ORGANIZATION-ID>"
  zone            = "fr-par-1"
  region          = "fr-par"
}

# https://www.terraform.io/docs/providers/scaleway/d/instance_volume.html
data "scaleway_instance_volume" "stateful" {
  name = "dev-stateful"
}

# https://www.terraform.io/docs/providers/scaleway/r/instance_server.html
resource "scaleway_instance_server" "dev" {
  type = "DEV1-S"
  image = "ubuntu_focal"
  enable_dynamic_ip = true

  name = 'dev'
  tags = [ "terraform", "autodelete" ]

  root_volume {
    size_in_gb = 20
    delete_on_termination = true
  }

  additional_volume_ids = [ data.scaleway_instance_volume.stateful.id ]

# https://cloudinit.readthedocs.io/en/latest/topics/examples.html
#  cloud_init = file("${path.module}/cloud-init.yml")
}

output "ip" {
  value = "${scaleway_instance_server.dev.ip}"
}
