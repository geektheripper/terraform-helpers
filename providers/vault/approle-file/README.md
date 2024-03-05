# Approle File

## Usage

Create approle and save role info to file.

```hcl
module "terraform_role" {
  source   = "github.com/geektheripper/terraform-helpers//providers/vault/approle-file/new"
  filename = "${path.module}/path/to/file.json"

  vault_addr    = var.vault_addr
  vault_backend = vault_auth_backend.terraform_role.path
  vault_role_id = "terraform"
  vault_mount   = vault_mount.terraform.path

  policy_document = <<EOF
path "auth/token/create" { capabilities = ["create", "read", "update", "list"] }

path "${vault_mount.terraform.path}/data/path/to/secret/*" { capabilities = ["read"] }
EOF
}
```

Parse role file and provid role info.

```hcl
module "vault" {
  source   = "github.com/geektheripper/terraform-helpers//providers/vault/approle-file"
  filename = "${path.module}/path/to/file.json"
}

provider "vault" {
  address = module.vault.address
  auth_login {
    path = module.vault.auth_login_path
    parameters = {
      role_id   = module.vault.role_id
      secret_id = module.vault.secret_id
    }
  }
}
```
