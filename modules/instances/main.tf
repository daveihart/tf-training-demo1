terraform {
    required_version = ">=0.14.8"
}

resource "aws_instance" "instance" {                                    # aws_instance resource type
    ami                    = var.ami                                    # the ami id
    iam_instance_profile   = var.iam_inst_prof                          # the instance profile/role to attach
    instance_type          = var.ec2_instance_size                      # the instance size
    subnet_id              = var.ec2_subnet                             # which subnet to deploy into
    vpc_security_group_ids = var.vpc_sg_ids                             # security groups
    key_name               = var.key_name                               # ssh key
    tags                   = merge(var.ec2_tags,{Name = var.ec2_name})  # tags
    user_data              = var.userdata                               # userdata to apply
}