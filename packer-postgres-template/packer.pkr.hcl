packer {
  required_plugins {
    cloudstack = {
      source  = "github.com/apache/cloudstack"
      version = ">= 0.1.0"
    }
  }
}

variable "template_name" {
  type    = string
  default = "rocky8-postgres-template-v1"
}

source "cloudstack" "postgres" {
  api_url          = "https://<cloudstack-api-url>"
  api_key          = "<cloudstack-api-key>"
  secret_key       = "<cloudstack-secret>"
  template         = "rocky8-base-image"
  service_offering = "4vCPU-16GB"
  zone             = "PrivateCloudZone"
  network          = "PrivateNetwork"
  ssh_username     = "cloud-user"
}

build {
  name    = "rocky8-postgres-template"
  sources = ["source.cloudstack.postgres"]

  provisioner "ansible" {
    playbook_file    = "ansible/site.yml"
    inventory_file   = "ansible/inventory.ini"
    extra_arguments  = ["--extra-vars", "jfrog_user=${env("JFROG_USER")} jfrog_pass=${env("JFROG_PASS")}"]
  }

  post-processor "cloudstack-template" {
    template_name  = var.template_name
    display_text   = "Rocky 8 PostgreSQL Template"
    format         = "QCOW2"
  }
}
