variable "aws_region" { type=string default="ap-south-1" }
variable "project_name" { type=string default="aws-devops-demo" }
variable "environment" { type=string default="dev" }
variable "vpc_cidr" { type=string default="10.20.0.0/16" }
variable "public_subnet_cidr" { type=string default="10.20.1.0/24" }
variable "instance_type" { type=string default="t3.micro" }
variable "allowed_ssh_cidr" { type=string description="Your public IP in CIDR form, e.g. 1.2.3.4/32" }
