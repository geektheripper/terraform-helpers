terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}

variable "filename" {
  type        = string
  description = "The path to the file to write the AppRole credentials to"
}

variable "vault_addr" {
  type        = string
  description = "The address of the Vault server"
}

variable "vault_backend" {
  type        = string
  description = "The backend to use for the AppRole"
}

variable "vault_role_id" {
  type        = string
  description = "The role_id of the AppRole, and will also be used as role name"
}

variable "vault_mount" {
  type        = string
  description = "The mount point of the AppRole"
}

variable "policy_document" {
  type        = string
  description = "The policy document to associate with the AppRole"
}

variable "extra" {
  type        = any
  description = "Extra configuration to pass to the AppRole"
  default     = {}
}

resource "vault_policy" "this" {
  name   = "terraform/${var.vault_role_id}"
  policy = var.policy_document
}

resource "vault_approle_auth_backend_role" "this" {
  backend        = var.vault_backend
  role_name      = var.vault_role_id
  role_id        = var.vault_role_id
  token_policies = [vault_policy.this.id]

  token_explicit_max_ttl = 3600
}

resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = var.vault_backend
  role_name = vault_approle_auth_backend_role.this.role_name
}

resource "local_file" "infra_base_secret_id" {
  filename        = var.filename
  file_permission = "0600"
  content = jsonencode({
    address         = var.vault_addr
    backend         = var.vault_backend
    auth_login_path = "auth/${var.vault_backend}/login"
    role_id         = vault_approle_auth_backend_role.this.role_id
    secret_id       = vault_approle_auth_backend_role_secret_id.this.secret_id
    mount           = var.vault_mount
    extra           = jsonencode(var.extra)
  })
}
