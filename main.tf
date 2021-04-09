terraform {
    backend "azurerm" {
    }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region  = var.region
  profile = var.profile
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

module "vpc" {
  source                   = "terraform-aws-modules/vpc/aws"
  version                  = "2.77.0"
  cidr                     = "10.0.0.0/16"
  azs                      = data.aws_availability_zones.available.names
  private_subnets          = ["10.0.2.0/28", "10.0.4.0/28"]
  public_subnets           = ["10.0.1.0/28"]
  enable_dns_hostnames     = true
  enable_nat_gateway       = true
  single_nat_gateway       = true
  public_subnet_tags = {
    Name = "${var.env_prefix}-public"
  }
  tags = var.tags
  vpc_tags = {
    Name = "${var.env_prefix}-VPC"
  }
  private_subnet_tags = {
    Name = "${var.env_prefix}-private"
  }
  igw_tags = {
    Name = "${var.env_prefix}-igw"
  }
   nat_gateway_tags = {
    Name = "${var.env_prefix}-natgw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "security-group-prometheus" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name = "SGAllowPrometheus"
  vpc_id = module.vpc.vpc_id
  tags = merge(
    var.tags, {
      Name = "SgAllowPrometheus"
  })
  ingress_with_cidr_blocks = [
    {
      from_port   = 9090
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9182
      to_port     = 9182
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },]
    egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "security-group-proxy" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name = "SgAllowProxy"
  vpc_id = module.vpc.vpc_id

  tags = merge(
    var.tags, {
      Name = "SgAllowProxy"
  })
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["http-80-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "instance_profile" {
  source      = "./modules/instance_profile"                             # where we created our configuration
  ip_name     = "demo_ec2_profile"                                       # instance profile name
  role_name   = "demo_ssm_role"                                          # role name
  policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] # list of policy arn to attach
  tag_name    = "demo-ec2-ssm-policy"                                    # the tag key name value
  tags        = var.tags
}

data "aws_ami" "aws-linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "proxy_server" {
  source            = "./modules/instances"
  count             = 1
  ec2_name          = "${"core-proxy"}${format("%02d",count.index+1)}"
  key_name          = var.key_name
  ec2_subnet        = module.vpc.public_subnets[0]
  vpc_sg_ids        = [module.security-group-prometheus.this_security_group_id, module.security-group-proxy.this_security_group_id]
  ami               = data.aws_ami.aws-linux2.id
  iam_inst_prof     = module.instance_profile.iam_instance_profile_name
  ec2_instance_size = var.instance_size["proxy"]
  ec2_tags          = var.tags
  userdata          = templatefile("./templates/proxy.tpl",{proxy_server = ("core-proxy${format("%02d",count.index+1)}"), prom_server = module.prometheus_server[count.index].private_ip})
}

module "prometheus_server" {
  source            = "./modules/instances"
  count             = 1
  ec2_name          = "${"core-prom"}${format("%02d",count.index+1)}"
  key_name          = var.key_name
  ec2_subnet        = module.vpc.private_subnets[0]
  vpc_sg_ids        = [module.security-group-prometheus.this_security_group_id, module.security-group-proxy.this_security_group_id]
  ami               = data.aws_ami.aws-linux2.id
  iam_inst_prof     = module.instance_profile.iam_instance_profile_name
  ec2_instance_size = var.instance_size["prometheus"]
  ec2_tags          = var.tags
  userdata          = templatefile("./templates/prometheus.tpl", {prometheus_server = ("core-prom${format("%02d",count.index+1)}")})
}