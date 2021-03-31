terraform {
    required_version = ">=0.14.8"
}

# Define the resource group for hosting the storage account
resource "azurerm_resource_group" "demo" {
  name     = var.rg_name
  location = var.rg_location
  tags = merge(
    var.tags, {
      Name = "var.rg_name"
  })
}

# Our storage account needs a globally unique name so we will use a 
# random integer terraform resource to help with the naming
resource "random_integer" "stacc_num" {
  min = var.random_min
  max = var.random_max
}

# Define the storage account
resource "azurerm_storage_account" "stacc" {
  name                     = "${lower(var.stacc_name_prefix)}${random_integer.stacc_num.result}"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = var.rg_location
  account_tier             = var.acc_tier
  account_replication_type = var.acc_rep_type
}

# Create the container within the storage account
resource "azurerm_storage_container" "ct" {
  name                 = var.container_name
  storage_account_name = azurerm_storage_account.stacc.name
}

# To access the storage account we need a SAS token. This is actually a data source
data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.stacc.primary_connection_string
  https_only        = true
  resource_types {
    service   = true
    container = true
    object    = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start = var.sas_start
  expiry = timeadd(var.sas_start, var.sas_timeadd)

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

resource "null_resource" "post-deploy" {
  depends_on = [azurerm_storage_container.ct]
  provisioner "local-exec" {
  command = <<EOT
  echo 'storage_account_name = "${azurerm_storage_account.stacc.name}"' >> ${var.sas_output_file}
  echo 'container_name = "tf-state"' >> ${var.sas_output_file}
  echo 'key = "terraform.tfstate"' >> ${var.sas_output_file}
  echo 'sas_token = "${data.azurerm_storage_account_sas.state.sas}"' >> ${var.sas_output_file}
  EOT
}
}