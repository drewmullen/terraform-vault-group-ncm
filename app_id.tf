resource "vault_identity_group" "group" {
  name     = var.app_id
  type     = "internal"
  policies = ["test"]
}

data "vault_policy_document" "app" {
  rule {
    path         = "tfvp/${var.app_id}*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }
}

resource "vault_policy" "app" {
  name   = var.app_id
  policy = data.vault_policy_document.app.hcl
}