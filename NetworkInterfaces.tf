/*----------------------------------------------------------------------------------------*/
#NETWORK INTERFACES FOR THE HIGH AVAILABILITY SOLUTION
/*----------------------------------------------------------------------------------------*/
#1'st interface
# resource "azurerm_network_interface" "webAppNetInterface1" {
#   name                = "webAppNetInterface1-nic"
#   location            = azurerm_resource_group.RG.location
#   resource_group_name = azurerm_resource_group.RG.name

#   ip_configuration {
#     name                          = "internal1"
#     subnet_id                     = azurerm_subnet.Web_Tier.id
#     private_ip_address_allocation = "Dynamic"
#     # public_ip_address_id          = azurerm_public_ip.LoadBalacerPublicIp.id

#   }
# }
# #2'nd
# resource "azurerm_network_interface" "webAppNetInterface2" {
#   name                = "webAppNetInterface2-nic"
#   location            = azurerm_resource_group.RG.location
#   resource_group_name = azurerm_resource_group.RG.name

#   ip_configuration {
#     name                          = "internal2"
#     subnet_id                     = azurerm_subnet.Web_Tier.id
#     private_ip_address_allocation = "Dynamic"

#   }
#  }
# #3'rd interface
# resource "azurerm_network_interface" "webAppNetInterface3" {
#   name                = "webAppNetInterface3-nic"
#   location            = azurerm_resource_group.RG.location
#   resource_group_name = azurerm_resource_group.RG.name

#   ip_configuration {
#     name                          = "internal3"
#     subnet_id                     = azurerm_subnet.Web_Tier.id
#     private_ip_address_allocation = "Dynamic"

#   }
# }
/*----------------------------------------------------------------------------------------*/