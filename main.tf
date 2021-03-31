terraform {
    backend "azurerm" {
    }
}

provider "azurerm" {
  features {}
}

module "azure_remote_state" {
  source            = "./modules/remote_state"
  random_min        = 100000
  random_max        = 999999
  rg_name           = "demo-rg"
  rg_location       = "UK West"
  stacc_name_prefix = "demonstration"
  acc_tier          = "standard"
  acc_rep_type      = "LRS"
  container_name    = "tf-state"
  sas_start         = timestamp()   #"2021-03-30T07:00:00Z"
  sas_timeadd       = "48h"
  sas_output_file   = "sas-remote-state.txt"
}