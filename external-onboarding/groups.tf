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

data "vault_policy_document" "ro" {
  for_each = keys(local.app_map)

  rule {
    path         = "tfvp/data/${each.key}/*"
    capabilities = ["read", "list"]
    description  = "allow all on secrets"
  }
}

# individual secret policies
data "vault_policy_document" "rw" {
  for_each = keys(local.app_map)

  dynamic rule {
    for_each = local.app_map[each.key].kvv2
    #each.value.kvv2
    content {
      path         = "tfvp/data/${each.key}/${each.rule}"
      capabilities = ["create", "read", "update", "list"]
      description  = "allow CRUL on specific secrets"  
    }
  }
}

locals {
  policies = { for k,v in local.id_names: k => "${data.vault_policy_document.ro[k].hcl}\n${data.vault_policy_document.rw[k].hcl}}" }
}

resource "vault_policy" "app" {
  for_each = toset(local.id_names)

  name   = each.key
  policy = local.policies[each.key]
}

resource "vault_identity_group" "group" {
  for_each = toset(local.id_names)

  name     = each.key
  type     = "internal"
  policies = [
    vault_policy.app[each.key].name
    
  ]
}