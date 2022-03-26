variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "Week_5_terraform"
  type        = string
}
variable "prefix" {
  type = map(string)
  default = {
    VnetName         = "HighAvailability"
    AppServerName1   = "AppServer1"
    AppServerName2   = "AppServer2"
    AppServerName3   = "AppServer3"
    PgDataServerName = "PgDataServer"

  }
}

variable "address_space" {
  type    = list(any)
  default = ["10.30.0.0/16"]
}

variable "location" {
  type        = string
  description = "Azure location of terraform server environment"
  default     = "East US"
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "Password@123"
}
