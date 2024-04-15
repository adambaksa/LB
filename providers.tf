terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "bf9b83d8-67d1-4691-9cb8-3de759b0fa86"
  client_id       = "383dcc0f-3f11-44c1-8b29-032f7f25ad7a"
  client_secret   = "~ec8Q~Er1LCv_8nKZZDqmS-tFV~-bi.3x_r.rbq7"
  tenant_id       = "e70d904c-182f-4d56-9452-4421819e0ff3"
  features {}
}