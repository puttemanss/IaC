terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.66.0"
    }
  }

  backend "azurerm" {

  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
}

provider "databricks" {
  host       = local.databricks_host
  account_id = var.databricks_account_id
}
