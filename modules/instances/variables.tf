variable "ec2_instance_size" {
    type = string
    default = "t2.micro"
}
variable "key_name" {
    type = string
}
variable "ec2_name" {
    type = string
}
variable "ec2_tags" {
  description = "resource tags"
  type        = map(any)
  default =   {}
}
variable "iam_inst_prof" {
  description = "IAM Instance profile name"
  type        = string
  default     = ""
}
variable "userdata" {
  description = "user_data template by type"
  type        = string
  default     = ""
}
variable "ec2_subnet" {
  description = "user_data template by type"
  type        = string
  default     = ""
}
variable "vpc_sg_ids" {
    description = "list of security groups"
    type = list
    default = [""]
}
variable "ami" {
  description = "AWS ami to use for instance"
  type        = string
  default     = ""
}