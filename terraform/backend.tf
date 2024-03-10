terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.27"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "stapplicationterraform"
    container_name       = "tfstatefile-apps"
    key                  = "albumui.tfstate"
  }
}
provider "azurerm" {
  features {}
}