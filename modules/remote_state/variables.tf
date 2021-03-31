variable "rg_name" {
  type    = string
  default = "example"
}

variable "rg_location" {
  description = "azure location"
  type        = string
  default     = "UK West"
}

variable "tags" {
  description = "resource tags"
  type        = map(any)
  default = {}
}

variable "random_min" {
    description = "minimum value for random number range"
    type = number
    default = 10000
}

variable "random_max" {
    description = "maximum value for random number range"
    type = number
    default = 99999
}
variable "stacc_name_prefix" {
    description = "prefix for the azure storage account name - random value will be added as suffix"
    type = string
    default = "example"
}
variable "acc_tier" {
  description = "azure storage tier"
  type        = string
  default     = "standard"
}
variable "acc_rep_type" {
  description = "azure replication type"
  type        = string
  default     = "LRS"
}
variable "container_name" {
  description = "azure storage account container name"
  type        = string
  default     = "demo"
}
variable "sas_start" {
  description = "Start time for SAS token expiration"
  type        = string
  default     = "timestamp()"
}
variable "sas_timeadd" {
  description = "time to add to sas token start time which calculates the expiration duration"
  type        = string
  default     = "24h"
}
variable "sas_output_file" {
  description = "output file containing sas details for remote state"
  type        = string
  default     = "example.txt"
}