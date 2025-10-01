# Déclarer un local ou variable avec le nom et la région pour chaque RG
locals {
  resource_groups = {
    "rg-dev"  = "eastus"
    "rg-test" = "eastus"
    "rg-prod" = "eastus"
  }
}

# Création multiple de groupes de ressources avec for_each sur la map
resource "azurerm_resource_groups" "rg" {
  for_each = local.resource_groups

  name     = each.key         # Les clés : rg-dev, rg-test, rg-prod
  location = each.value       # La valeur : "eastus" pour tous
}

