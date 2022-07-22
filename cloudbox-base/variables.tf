variable "tags" {
    type = map(string)
    default = {
        "project": "cloudbox"
    }
}

variable "location" {
    type = string
    default = "Canada Central"
}

variable "username" {
    type = string
    description = "Username of the default administrator"
    default = "azureadmin"
}

variable "password" {
    type = string
    description = "Password used for workload VMs. NOT MEANT TO BE A PRODUCTION-GRADE setup"
}

variable "bootstrap_options" {
    type = string
    description = "Custom data sent to the VM-Series to license it"
}

variable "subnet_set" {
    type = list(string)
    description = "Map of the different subnets to create"
    default = null
}