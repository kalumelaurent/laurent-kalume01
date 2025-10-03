terraform{
  required_providers{
    azurerm={
      source="hashicorp/azurerm"
      version= ">=3.70.0"#this version is for azurerm, NOT terraform version
    }
  }
  required_version=">=1.4.0"#this version is for Terraform Version, NOT azurerm
}

provider "azurerm"{
  features{}  
  subscription_id=var.subscription_id
  client_id=var.client_id
  client_secret=var.client_secret
  tenant_id=var.tenant_id
}








    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}


resource "random_string" "apim_suffix" {
  length  = 5
  upper   = false
  numeric = true
  special = false
}

locals {
  rg_name   = "rg-apim-product-mcit"
  apim_name = "mcit-apim-${random_string.apim_suffix.result}"
  apis = {
    api1 = { display_name = "API One",   path = "api-one"   }
    api2 = { display_name = "API Two",   path = "api-two"   }
    api3 = { display_name = "API Three", path = "api-three" }
    api4 = { display_name = "API Four",  path = "api-four"  }
    api5 = { display_name = "API Five",  path = "api-five"  }
  }
  mcit_openapi_url = "https://petstore.swagger.io/v2/swagger.json"
}


resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_api_management" "apim" {
  name                = local.apim_name   # ← nom unique via random_string
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Developer_1"
}
# ...reste de ta configuration identique
