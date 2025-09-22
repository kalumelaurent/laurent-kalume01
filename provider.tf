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

# Définition du fournisseur Azure avec les fonctionnalités par défaut
# Cette approche permet de déployer la même application dans 5 régions différentes en une seule configuration 
provider2 "azurerm" {
  features {}
}
