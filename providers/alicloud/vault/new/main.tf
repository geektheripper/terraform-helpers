terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}

variable "vault_mount" {
  type        = string
  description = "The mount point to save the alicloud credentials"
}

variable "vault_key" {
  type        = string
  description = "The key to save the alicloud credentials"
}

variable "region" {
  type        = string
  description = "The region to create the user in"
  default     = "cn-hangzhou"
}

variable "user_name" {
  type        = string
  description = "The name of the user"
}

variable "display_name" {
  type        = string
  description = "The display name of the user"
  default     = null
}

variable "policy_name" {
  type        = string
  description = "The name of the policy to attach to the user"
}

variable "policy_type" {
  type        = string
  description = "The type of the policy to attach to the user"
  default     = "System"
}

variable "extra" {
  type        = any
  description = "Extra configuration to save with the alicloud credentials"
  default     = {}
}

locals {
  display_name = var.display_name != null ? var.display_name : "Terrform Managed User: ${var.user_name}"
}

resource "alicloud_ram_user" "this" {
  name         = var.user_name
  display_name = local.display_name
}

resource "alicloud_ram_user_policy_attachment" "this" {
  user_name   = alicloud_ram_user.this.name
  policy_name = var.policy_name
  policy_type = var.policy_type
}

resource "alicloud_ram_access_key" "this" { user_name = alicloud_ram_user.this.name }

resource "vault_kv_secret_v2" "this" {
  mount = var.vault_mount
  name  = var.vault_key

  delete_all_versions = true

  data_json = jsonencode({
    region     = var.region
    access_key = alicloud_ram_access_key.this.id
    secret_key = alicloud_ram_access_key.this.secret
    extra      = jsonencode(var.extra)
  })
}
