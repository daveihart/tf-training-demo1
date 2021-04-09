variable "region" {
  description = "aws region"
  type        = string
  default     = "eu-west-2"
}
variable "profile" {
  description = "aws user profile to utilise"
  type        = string
  default     = "capgemini"
}
variable "tags" {
  description = "resource tags"
  type        = map(any)
  default = {
    CostCentre : "common"
    Project : "demo"
    Description : "Demonstration"
    Owner : "dave.hart"
  }
}
variable "env_prefix" {
  description = "prefix for naming"
  type        = string
  default     = "demo"
}
variable "key_name" {
  description = "ec2 keypair"
  type        = string
  default     = "demo"
}
variable "instance_size" {
  description = "instance tppe mapped to role"
  type        = map(any)
  default = {
    prometheus = "t2.micro"
    proxy      = "t2.micro"
  }
}