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
