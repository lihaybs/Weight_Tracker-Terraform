
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
resource "azurerm_resource_group" "RG" {
  name     = "Week5ProjectNet"
  location = var.location
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Create a virtual network
/*----------------------------------------------------------------------------------------*/
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix.VnetName}-Net"
  address_space       = var.address_space
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Creat a subnet for the data base
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "Data_Tier" {
  name                 = "Data_Tier"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.2.0/24"]
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.3.0/24"]
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Creat a subnet for the app servers
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "Web_Tier" {
  name                 = "Web_Tier"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.1.0/24"]
  # sku                 = "Standard"

}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Azure Public Ip for Load Balancer
/*----------------------------------------------------------------------------------------*/
resource "azurerm_public_ip" "LoadBalacerPublicIp" {
  name                = "LoadBalacerPublicIp"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
/*----------------------------------------------------------------------------------------*/




/*----------------------------------------------------------------------------------------*/
# A NETWORK SECURITY GROUP PLUS AN ASSOSIATION TO THE WEB TIER SUBNET 
# this network security group will have the azure standard plus an openning of port 8080 
#  to startlistaning for app request 
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet_network_security_group_association" "NSG1" {
  subnet_id                 = azurerm_subnet.Web_Tier.id
  network_security_group_id = azurerm_network_security_group.NSG1.id
}

resource "azurerm_network_security_group" "NSG1" {
  name                = "NSG1"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name


}
resource "azurerm_network_security_rule" "Allow_8080" {
  name                        = "test123"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.RG.name
  network_security_group_name = azurerm_network_security_group.NSG1.name
}

/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
/* A NETWORK SECURITY GROUP PLUS AN ASSOSIATION TO THE DATA TIER SUBNET                   */
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet_network_security_group_association" "NSG2_association" {
  subnet_id                 = azurerm_subnet.Data_Tier.id
  network_security_group_id = azurerm_network_security_group.NSG2.id
}
/* BECAUSE WE WANT THE DATA TIER TO REMAINE "HIDDEN" TO OUTSIDE EYES WE CAN LEAVE THE STANDARD  */
/* AZURE NSG BLOCK THAT ALLOWS ONLY INSIDE NETWORK COMUNICATIONS                                */
resource "azurerm_network_security_group" "NSG2" {
  name                = "NSG2"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name


}
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
# SIMPLE LOAD BALANCER BLOCK
/*----------------------------------------------------------------------------------------*/
resource "azurerm_lb" "App-LoadBalacer" {
  name                = "App-LoadBalacer"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.LoadBalacerPublicIp.id
  }


}
/*----------------------------------------------------------------------------------------*/



/*Configuring the load balncer inbound rule to allow outside access to the load balancer(Like a NSG)*/
resource "azurerm_lb_rule" "AcceseRole" {
  resource_group_name            = azurerm_resource_group.RG.name
  loadbalancer_id                = azurerm_lb.App-LoadBalacer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.AppScaleSet.id]
  probe_id                       = azurerm_lb_probe.Helthprobe.id
}

# /*Configuring nat rule for RDP connection to the backend pool through the load balancer*/
# resource "azurerm_lb_nat_rule" "SSH_Access" {
#   resource_group_name            = azurerm_resource_group.RG.name
#   loadbalancer_id                = azurerm_lb.App-LoadBalacer.id
#   name                           = "SSH_Access"
#   protocol                       = "Tcp"
#   frontend_port                  = 22
#   backend_port                   = 22
#   frontend_ip_configuration_name = "frontend-ip"

# }


# resource "azurerm_lb_outbound_rule" "OutboundRule" {
#   resource_group_name     = azurerm_resource_group.RG.name
#   loadbalancer_id         = azurerm_lb.App-LoadBalacer.id
#   name                    = "OutboundRule"
#   protocol                = "Tcp"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.AppServerPool.id

#   frontend_ip_configuration {
#     name = "frontend-ip"
#   }
# }

/*----------------------------------------------------------------------------------------*/
#CREATING BACKEND POOL's FOR THE LOAD BALANCER
/*----------------------------------------------------------------------------------------*/
#Poll for Scale set "elastic" infrastracture
resource "azurerm_lb_backend_address_pool" "AppScaleSet" {
  loadbalancer_id = azurerm_lb.App-LoadBalacer.id
  name            = "AppScaleSet"
  depends_on = [
    azurerm_lb.App-LoadBalacer
  ]
}

#Pool for three vm's inferstracture

# resource "azurerm_lb_backend_address_pool" "AppServerPool" {
#   loadbalancer_id = azurerm_lb.App-LoadBalacer.id
#   name            = "AppServerPool"
#   depends_on = [
#     azurerm_lb.App-LoadBalacer
#   ]
# }
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
# #Adding vm's to the backend pool
/*----------------------------------------------------------------------------------------*/
# resource "azurerm_lb_backend_address_pool_address" "AppServer1" {
#   name                    = "AppServer1"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.AppServerPool.id
#   virtual_network_id      = azurerm_virtual_network.vnet.id
#   ip_address              = azurerm_network_interface.webAppNetInterface1.private_ip_address
# }
# resource "azurerm_lb_backend_address_pool_address" "AppServer2" {
#   name                    = "AppServer2"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.AppServerPool.id
#   virtual_network_id      = azurerm_virtual_network.vnet.id
#   ip_address              = azurerm_network_interface.webAppNetInterface2.private_ip_address
# }
# resource "azurerm_lb_backend_address_pool_address" "AppServer3" {
#   name                    = "AppServer3"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.AppServerPool.id
#   virtual_network_id      = azurerm_virtual_network.vnet.id
#   ip_address              = azurerm_network_interface.webAppNetInterface3.private_ip_address

# }
/*-------------------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
#PROBE BLOCK REQUIRED FOR THE OPERATION OF LOAD BALNCER
/*----------------------------------------------------------------------------------------*/
resource "azurerm_lb_probe" "Helthprobe" {
  resource_group_name = azurerm_resource_group.RG.name
  loadbalancer_id     = azurerm_lb.App-LoadBalacer.id
  name                = "Helthprobe"
  port                = 8080
}
/*----------------------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------------------*/
#BASTION SERVER BLOCK
#PROVIDING A SECURE WAY INTO OUR VIRTUAL NETWORK TO REACH THE VM'S AND DATA SERVERS
/*----------------------------------------------------------------------------------------*/
resource "azurerm_public_ip" "BastionPublicIp" {
  name                = "BastionPublicIp"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionServer" {
  name                = "BastionServer"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.BastionPublicIp.id
  }
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
#NETWORK INTERFACES FOR THE POSTGRES DATA SERVER
/*----------------------------------------------------------------------------------------*/
resource "azurerm_network_interface" "PgDataServer" {
  name                = "PgDataServer-nic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Data_Tier.id
    private_ip_address_allocation = "Dynamic"

  }
}
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
#THIS IS A LINUX VIRTUAL MACHINE FOR THE DATA BASE IT HAS SOME SPACIEL FUNCTIONALITYS 
#THAT ARE EXPLAIND IN DETAILE INSIDE THE BLOCK
/*----------------------------------------------------------------------------------------*/
resource "azurerm_linux_virtual_machine" "PgDataServer" {
  name                = "${var.prefix.PgDataServerName}-vm"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_F2"
  /*---------required section choosing-----*/
  /*  to connect via user name and password  */
  /*--instead of the usuale ssh safer mathod----*/
  admin_username                  = "adminuser"
  admin_password                  = "Hakolzorem2022"
  disable_password_authentication = false
  /*------------------------------------------------------*/
  network_interface_ids = [
    azurerm_network_interface.PgDataServer.id,
  ]

  /*---------------------------------------*/
  # this line run's a script with command line 
  #  that configurate the postgres server
  /*---------------------------------------*/
  custom_data = filebase64("DataServerRunUp.sh")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# THIS IS A LINUX MACHINE SCALE SET FOR THE ELASTIC SOLUTION AGAIN THERE ARE SPECIEL FETURE'S
# THAT ARE DIFFERNT FROM THE MINIMUM STANDARD REQUIRMENTS AND THAT ARE CUSTOMED TO OUR NEEDS
/*----------------------------------------------------------------------------------------*/
resource "azurerm_linux_virtual_machine_scale_set" "AppScaleSet" {
  name                = "AppScaleSet"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  sku                 = "Standard_F2"
  instances           = 2
  /*---------required section choosing-----*/
  /*  to connect via user name and password  */
  /*--instead of the usuale ssh safer mathod----*/
  admin_username                  = "adminuser"
  admin_password                  = "Hakolzorem2022"
  disable_password_authentication = false
  /*---------------------------------------------*/
  upgrade_mode = "Automatic"


  /*---------------------------------------*/
  # this line run's a script with command line 
  #  that configurate the App on the instances 
  #              when created 
  /*---------------------------------------*/
  custom_data = filebase64("RunUp.sh")


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "AppScaleSet-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.Web_Tier.id

      /*  this line connects the scaile set to a backend pool      */
      /*  of the load balancer we want to hanlde th...well load :) */
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.AppScaleSet.id]
      #TODO: להוסיף את היכולת לגדול לפי הצורך
    }
  }
  # lifecycle { 
  #   ignore_changes = ["instances"]
  # }


}
/*----------------------------------------------------------------------------------------*/
