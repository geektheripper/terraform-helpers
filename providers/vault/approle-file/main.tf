variable "filename" {
  type        = string
  description = "The path to AppRole credentials file"
}

locals { secret = jsondecode(file(var.filename)) }

output "address" { value = lookup(local.secret, "address", null) }
output "backend" { value = lookup(local.secret, "backend", null) }
output "auth_login_path" { value = lookup(local.secret, "auth_login_path", null) }
output "role_id" { value = lookup(local.secret, "role_id", null) }
output "secret_id" {
  value     = lookup(local.secret, "secret_id", null)
  sensitive = true
}
output "mount" { value = lookup(local.secret, "mount", null) }
output "extra" { value = jsondecode(lookup(local.secret, "extra", "{}")) }
