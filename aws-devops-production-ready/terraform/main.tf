data "aws_ami" "amazon_linux" {
  most_recent=true
  owners=["amazon"]
  filter { name="name" values=["al2023-ami-*-x86_64"] }
  filter { name="state" values=["available"] }
}
resource "aws_vpc" "main" {
  cidr_block=var.vpc_cidr
  enable_dns_support=true
  enable_dns_hostnames=true
}
resource "aws_internet_gateway" "main" { vpc_id=aws_vpc.main.id }
resource "aws_subnet" "public" {
  vpc_id=aws_vpc.main.id
  cidr_block=var.public_subnet_cidr
  availability_zone="${var.aws_region}a"
  map_public_ip_on_launch=true
}
resource "aws_route_table" "public" {
  vpc_id=aws_vpc.main.id
  route { cidr_block="0.0.0.0/0" gateway_id=aws_internet_gateway.main.id }
}
resource "aws_route_table_association" "public" {
  subnet_id=aws_subnet.public.id
  route_table_id=aws_route_table.public.id
}
resource "aws_security_group" "app" {
  name="${var.project_name}-sg"
  vpc_id=aws_vpc.main.id
  ingress { from_port=8080 to_port=8080 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=22 to_port=22 protocol="tcp" cidr_blocks=[var.allowed_ssh_cidr] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_iam_role" "ec2" {
  name="${var.project_name}-ec2-role"
  assume_role_policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Principal={Service="ec2.amazonaws.com"},Action="sts:AssumeRole"}]})
}
resource "aws_iam_instance_profile" "ec2" { name="${var.project_name}-profile" role=aws_iam_role.ec2.name }
resource "aws_instance" "app" {
  ami=data.aws_ami.amazon_linux.id
  instance_type=var.instance_type
  subnet_id=aws_subnet.public.id
  vpc_security_group_ids=[aws_security_group.app.id]
  iam_instance_profile=aws_iam_instance_profile.ec2.name
  user_data=<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
  EOF
  monitoring=true
}
