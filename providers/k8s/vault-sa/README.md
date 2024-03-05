# K8s Service Account in Vault

## Usage

Create service account for k8s, and save secret to vault.

```hcl
module "kubernetes_admin" {
  source = "github.com/geektheripper/terraform-helpers//providers/terraform/vault-sa/new"

  vault_mount = module.vault.mount
  vault_key   = "path/to/secret"

  name      = "terraform-admin"
  namespace = "kube-system"

  host                   = data.vault_kv_secret_v2.root_acc.data["host"]
  cluster_ca_certificate = data.vault_kv_secret_v2.root_acc.data["cluster_ca_certificate"]

  extra = {
    cluster_domain = "xxxx.example.com"
    foo = "bar"
  }
}
```

Load secret and provide parameters to k8s provider.

```hcl
module "kubernetes" {
  source = "github.com/geektheripper/terraform-helpers//providers/terraform/vault-sa"

  vault_mount = module.vault.mount
  vault_key   = "path/to/secret"
}

provider "kubernetes" {
  host                   = module.kubernetes.host
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  token                  = module.kubernetes.token
}

# module.kubernetes.extra.cluster_domain
```
