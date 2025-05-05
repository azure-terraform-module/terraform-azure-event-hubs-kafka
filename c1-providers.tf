terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
 }

provider "azurerm" {
  features {}
  subscription_id = "0d628cd3-702c-4966-abd0-871c98f5b72f"
}
