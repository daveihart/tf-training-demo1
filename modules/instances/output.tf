output "public_ip" {
  value = join("", aws_instance.instance[*].public_ip)
}

output "private_ip" {
    value = join("", aws_instance.instance[*].private_ip)
}