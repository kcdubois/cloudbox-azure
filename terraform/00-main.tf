terraform {
    cloud {
        organization = "panw-iac-lab"

        workspaces {
            name = "cloudbox-azure"
        }
    }

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }

        random = {
            source = "hashicorp/random"
        }
    }
}

provider "azurerm" {
    features {}
}