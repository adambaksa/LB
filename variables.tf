variable "location" {
  type        = string
  description = "The location where resources will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine."
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type        = string
  description = "The admin username for the Virtual Machine."
}

variable "admin_password" {
  type        = string
  description = "The admin password for the Virtual Machine."
}

variable "address_space" {
  type        = list(string)
  description = "The address space for the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "The address prefixes for the subnet."
  default     = ["10.0.0.0/24"]
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account."
}

variable "container_name" {
  type        = string
  description = "The name of the storage container."
  default     = "data"
}

/*
variable "blob_name" {
  type        = string
  description = "The name of the blob."
  default     = "IIS_Config.ps1"
}
*/
/*variable "source_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "The source image for the Virtual Machine."
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
*/
