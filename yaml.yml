
linux_app:
  - name: magne1-rg
    resource_group: magne1-rg
    location: canadacentral
    os_type: Linux
    sku_name: B1
    app_service_name: magne1-app


linux_app:
  - name: magne2-rg
    resource_group: magne2-rg
    location: canadacentral
    os_type: Linux
    sku_name: B1
    app_service_name: magne2-app

linux_app:
  - name: magne3-rg
    resource_group: magne3-rg
    location: canadacentral
    os_type: Linux
    sku_name: B1
    app_service_name: magne3-app


locals {
  linux_app = [
    for f in fileset("${path.module}/configs", "[^_]*.yaml") :
      yamldecode(file("${path.module}/configs/${f}"))
  ]

  linux_app_list = flatten([
    for app in local.linux_app : [
      for linuxapps in try(app.linux_app, []) : {
        name                = linuxapps.name
        resource_group_name = linuxapps.resource_group
        location            = linuxapps.location
        os_type             = linuxapps.os_type
        sku_name            = linuxapps.sku_name
        app_service_name    = linuxapps.app_service_name
      }
    ]
  ])
}


resource "azurerm_resource_group" "mcitexamplerg" {
  for_each = { for rg in local.linux_app_list : rg.resource_group_name => rg }
  name     = each.value.resource_group_name
  location = each.value.location
}


resource "azurerm_app_service_plan" "this" {
  for_each            = { for app in local.linux_app_list : app.app_service_name => app }
  name                = "plan-${each.value.app_service_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.mcitexamplerg[each.value.resource_group_name].name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = each.value.sku_name
  }
}

resource "azurerm_linux_web_app" "this" {
  for_each            = { for app in local.linux_app_list : app.app_service_name => app }
  name                = each.value.app_service_name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.mcitexamplerg[each.value.resource_group_name].name
  service_plan_id     = azurerm_app_service_plan.this[each.value.app_service_name].id
}
