data "aws_ssm_parameters_by_path" "apps" {
  path = "/vault-onboarded-app-ids"
}

locals {
  id_names = [for name in data.aws_ssm_parameters_by_path.apps.names : 
        split("/", name)[2]
  ]
  app_map = zipmap(
    local.id_names,
    data.aws_ssm_parameters_by_path.apps.values
  )
}

resource "vault_identity_group" "group" {
  for_each = toset(local.id_names)

  name     = each.key
  type     = "internal"
  policies = ["test"]
}

data "vault_policy_document" "app" {
  for_each = toset(local.id_names)

  rule {
    path         = "tfvp/${each.key}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }
}

resource "vault_policy" "app" {
  for_each = toset(local.id_names)

  name   = each.key
  policy = data.vault_policy_document.app.hcl
}