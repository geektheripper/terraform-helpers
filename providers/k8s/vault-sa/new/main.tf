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

variable "name" { type = string }
output "name" { value = var.name }
variable "namespace" { type = string }
output "namespace" { value = var.namespace }

variable "host" { type = string }
variable "cluster_ca_certificate" { type = string }

variable "extra" {
  type        = any
  description = "Extra configuration to save with the kubenretes credentials"
  default     = {}
}

resource "kubernetes_service_account" "terraform_admin" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_secret" "terraform_admin" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    annotations = { "kubernetes.io/service-account.name" = var.name }
  }
  type = "kubernetes.io/service-account-token"

  wait_for_service_account_token = true
}

resource "vault_kv_secret_v2" "this" {
  mount = var.vault_mount
  name  = var.vault_key

  delete_all_versions = true

  data_json = jsonencode({
    host                   = var.host
    cluster_ca_certificate = var.cluster_ca_certificate
    token                  = kubernetes_secret.terraform_admin.data["token"]
    extra                  = jsonencode(var.extra)
  })
}
