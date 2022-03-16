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

variable "password" {
    type = string
    description = "Password used for workload VMs. NOT MEANT TO BE A PRODUCTION-GRADE setup"
}

variable "bootstrap_options" {
    type = string
    description = "Custom data sent to the VM-Series to license it"
}