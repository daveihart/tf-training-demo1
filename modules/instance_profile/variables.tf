variable "ip_name" {
    type = string                # instance profile name
    default = ""
}

variable "role_name" {           # role name
    type = string
    default = ""
}
 
variable "tag_name" {            # tag name key value
    type = string
    default = ""
}

variable "policy_arns" {         # list of arns to attach to the role
  description = "arns to add to ec2 role"
  type        = list(any)
  default     = [""]
}

variable "tags" {                # tags to apply
  description = "resource tags"
  type        = map(any)
  default = {}
}