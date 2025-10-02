variable "webapps" {
  type = list(object({
    name             = string
    region           = string
    sku_name         = string
    worker_count     = number
  }))
  default = [
    { name = "myapp-eu-001",    region = "westeurope",       sku_name = "B1", worker_count = 1 },
    { name = "myapp-na-001",    region = "canadacentral",    sku_name = "P1v2", worker_count = 2 },
    { name = "myapp-asia-001",  region = "japaneast",        sku_name = "S1", worker_count = 3 },
    { name = "myapp-aus-001",   region = "australiaeast",    sku_name = "B2", worker_count = 1 },
  ]
}



resource "azurerm_resource_group" "rg" {
  for_each = { for app in var.webapps : app.region => app }
  name     = "rg-${each.value.name}"
  location = each.value.region
}




resource "azurerm_service_plan" "plan" {
  for_each            = { for app in var.webapps : app.region => app }
  name                = "sp-${each.value.name}"
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg[each.key].name
  os_type             = "Linux"
  sku_name            = each.value.sku_name
  worker_count        = each.value.worker_count
}


resource "azurerm_linux_web_app" "app" {
  for_each            = { for app in var.webapps : app.region => app }
  name                = each.value.name
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg[each.key].name
  service_plan_id     = azurerm_service_plan.plan[each.key].id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

