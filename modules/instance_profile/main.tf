terraform {
    required_version = ">=0.14.8"
}
                                   
resource "aws_iam_role" "demo-ssm-role" {               # Define our resource role for systems manager
  name = var.role_name                                  # the role name from a variables
  assume_role_policy = jsonencode({                     # use jsonencode to format the role policy to a string
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(
    var.tags, {
      Name = var.tag_name
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.ip_name                                      # variable to define the instance profile name
  role = aws_iam_role.demo-ssm-role.name                  # which role is associated with the instance profile
}

resource "aws_iam_role_policy_attachment" "ssm-attach" {  # define which existing policies to attach to the the role
  role       = aws_iam_role.demo-ssm-role.name            # name of the role
  count      = length(var.policy_arns)                    # loop through each policy arn defined in the variable
  policy_arn = var.policy_arns[count.index]
}