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
  for_each = toset(local.id_names)

  rule {
    path         = "tfvp/data/${each.key}/*"
    capabilities = ["read", "list"]
    description  = "allow all on secrets"
  }
}

# individual secret policies
data "vault_policy_document" "rw" {
  for_each = toset(local.id_names)

  dynamic rule {
    for_each = jsondecode(local.app_map[each.key]).kvv2
    content {
      path         = "tfvp/data/${each.key}/${rule.value}"
      capabilities = ["create", "read", "update", "list"]
      description  = "allow CRUL on specific secrets"  
    }
  }
}

locals {
  policies = { for k,v in toset(local.id_names): k => "${data.vault_policy_document.ro[k].hcl}\n${data.vault_policy_document.rw[k].hcl}" }
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

locals {
  secrets_by_id = [ for appid, appvalue in local.app_map: [for secret in jsondecode(appvalue).kvv2 : "${appid}/${secret}"] ]
}

resource "vault_kv_secret_v2" "hardcoded_secrets" {
  for_each = toset(nonsensitive(local.secrets_by_id))

  name                       = each.key
  mount                      = "tfvp"
  data_json                  = jsonencode({
    "drew" = "test"
  })
  lifecycle {
    ignore_changes = [ data_json ]
  }

  custom_metadata {
    data = {
      owner_email = local.app_map[split("/", each.key)[0]].owner_email
      description = local.app_map[split("/", each.key)[0]].description
    }
    
  }
}