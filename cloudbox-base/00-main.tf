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
    }
}

provider "azurerm" {
    features {
        virtual_machine {
            delete_os_disk_on_deletion     = false
            graceful_shutdown              = true
            skip_shutdown_and_force_delete = false
        }
    }
}