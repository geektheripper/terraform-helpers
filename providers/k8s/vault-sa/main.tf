terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}

variable "vault_mount" { type = string }
variable "vault_key" { type = string }

data "vault_kv_secret_v2" "this" {
  mount = var.vault_mount
  name  = var.vault_key
}

output "host" {
  value     = lookup(data.vault_kv_secret_v2.this.data, "host", null)
  sensitive = false
}
output "cluster_ca_certificate" {
  value     = lookup(data.vault_kv_secret_v2.this.data, "cluster_ca_certificate", null)
  sensitive = false
}
output "token" { value = lookup(data.vault_kv_secret_v2.this.data, "token", null) }
output "extra" {
  value     = jsondecode(lookup(data.vault_kv_secret_v2.this.data, "extra", "{}"))
  sensitive = false
}
