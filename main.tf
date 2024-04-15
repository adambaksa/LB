locals {
  resource_group = var.resource_group_name
}

resource "azurerm_resource_group" "app_grp"{
  name      = local.resource_group
  location  = var.location  
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = var.address_space  
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "subnet_a"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = var.subnet_prefixes
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

resource "azurerm_network_interface" "app_interface1" {
  name                = "app-interface1"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_a.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.subnet_a
  ]
}

resource "azurerm_network_interface" "app_interface2" {
  name                = "app-interface2"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_a.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.subnet_a
  ]
}

resource "azurerm_windows_virtual_machine" "app_vm1" {
  name                = "njevm01"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.app_interface1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface1,
    azurerm_availability_set.app_set
  ]
}

resource "azurerm_windows_virtual_machine" "app_vm2" {
  name                = "njevm02"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.app_interface2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface2,
    azurerm_availability_set.app_set
  ]
}


resource "azurerm_availability_set" "app_set" {
  name                = "app-set"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  platform_fault_domain_count = 3
  platform_update_domain_count = 3  
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_storage_account" "app_store" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  #allow_blob_public_access = true
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
  depends_on=[
    azurerm_storage_account.app_store
    ]
}

resource "azurerm_storage_blob" "IIS_config" {
  name                   = var.blob_name
  storage_account_name   = var.storage_account_name
  storage_container_name = var.container_name
  type                   = "Block"
  source                 = var.blob_name
   depends_on=[azurerm_storage_container.data]
}

resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.app_store.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_extension2" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.app_store.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_a.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}

resource "azurerm_public_ip" "load_ip" {
  name                = "load-ip"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_lb" "app_balancer" {
  name                = "app-balancer"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }
  sku="Standard"
  depends_on = [
    azurerm_public_ip.load_ip
   ]
}

resource "azurerm_lb_backend_address_pool" "pool_a" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "pool_a"

  depends_on = [
    azurerm_lb.app_balancer
   ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm1_address" {
  name                    = "njevm01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_a.id
  virtual_network_id      = azurerm_virtual_network.app_network.id
  ip_address              = azurerm_network_interface.app_interface1.private_ip_address
  depends_on = [ 
    azurerm_lb_backend_address_pool.pool_a 
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm2_address" {
  name                    = "njevm02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_a.id
  virtual_network_id      = azurerm_virtual_network.app_network.id
  ip_address              = azurerm_network_interface.app_interface2.private_ip_address
  depends_on = [ 
    azurerm_lb_backend_address_pool.pool_a 
  ]
}

resource "azurerm_lb_probe" "probe_a" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "probe_a"
  port            = 80
  depends_on = [
    azurerm_lb.app_balancer
  ]
}

resource "azurerm_lb_rule" "rule_a" {
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "rule_a"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.pool_a.id ]
  probe_id = azurerm_lb_probe.probe_a.id
  depends_on = [
    azurerm_lb.app_balancer,
    azurerm_lb_probe.probe_a
  ]
}