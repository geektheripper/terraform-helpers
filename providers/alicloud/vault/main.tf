terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}

variable "vault_mount" {
  type        = string
  description = "The mount point to alicloud credentials"
}

variable "vault_key" {
  type        = string
  description = "The key to alicloud credentials"
}

data "vault_kv_secret_v2" "this" {
  mount = var.vault_mount
  name  = var.vault_key
}

locals {
  region     = lookup(data.vault_kv_secret_v2.this.data, "region", "cn-hangzhou")
  access_key = lookup(data.vault_kv_secret_v2.this.data, "access_key", null)
  secret_key = lookup(data.vault_kv_secret_v2.this.data, "secret_key", null)
}

provider "alicloud" {
  region     = local.region
  access_key = local.access_key
  secret_key = local.secret_key
}

output "region" { value = local.region }
output "access_key" { value = local.access_key }
output "secret_key" { value = local.secret_key }
output "extra" { value = jsondecode(lookup(data.vault_kv_secret_v2.this.data, "extra", "{}")) }

variable "get_account_id" {
  type        = bool
  description = "Whether to get the account id"
  default     = false
}
data "alicloud_account" "this" { count = var.get_account_id ? 1 : 0 }
output "account_id" { value = var.get_account_id ? data.alicloud_account.this.0.id : null }
