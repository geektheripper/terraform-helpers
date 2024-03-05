# Alicloud RAM in Vault

## Usage

Create RAM user and save secret to vault.

```hcl
module "alicloud_admin" {
  source = "github.com/geektheripper/terraform-helpers//providers/alicloud/vault/new"

  vault_mount = vault_mount.terraform.path
  vault_key   = "path/to/secret"

  region = "cn-shanghai"

  user_name   = "terraform-admin"
  policy_name = "AdministratorAccess"

  extra = {
    vpc = xxxxxx
  }
}
```

Load secret and provide parameters to alicloud provider.

```hcl
module "alicloud" {
  source = "github.com/geektheripper/terraform-helpers//providers/alicloud/vault"

  vault_mount = module.vault.mount
  vault_key   = "path/to/secret"
}

provider "alicloud" {
  region     = module.alicloud.region
  access_key = module.alicloud.access_key
  secret_key = module.alicloud.secret_key
}

# module.alicloud.extra.vpc
```
