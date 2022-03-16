# cloudbox-azure
Cloudbox is designed to be a lab environment for testing PAN-OS and Panorama features and is not meant to be used AS IS in a production environment for the lack of redundancy and scalability lost at the expense of cost savings. This is meant to be as close as possible to a 1-click-to-deploy environment by running the Terraform workspace with Terraform Cloud for remote state management and variable management.

For a best practice deployment, please follow the VM-Series in Azure Reference Architecture with the related Terraform modules to get started easily.

## Resources deployed in the environment
* Virtual Network and subnets
* Bastion Host
* VM-series and Panorama
* Windows Server 2019 for critical services
* Linux server for DAAS
* Windows 10 user
