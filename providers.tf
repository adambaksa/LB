terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "9485e662-9561-4893-9a75-0d40e8f34cf4"
  client_id       = "fe82ff81-626a-43f2-8e31-fb820bcda123"
  client_secret   = "rcF8Q~3Ui4cHtzK~4.H2LE45pOP0McT.0kFIlcyN"
  tenant_id       = "3189c4b9-8fbc-4f43-bda6-fdba77119c88"
  features {}
}
