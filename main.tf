//cloud provider chosen in ireland region
provider "aws" { 
  region = "eu-west-1"
}

//variables
variable "ingressrules" {
  type    = list(number)
  default = [22, 80, 443]
}
variable "egressrules" {
  type    = list(number)
  default = [22, 80, 443]
}
variable "subnet" {
  default = "172.30.0.0/24"
}
variable "cidr_block" {
  default = "172.30.0.0/16"
}

//VPC within a ip range of "172.30.0.0/16"
resource "aws_vpc" "MyVPC2" {
  cidr_block  = var.cidr_block
  tags = {
    Name = "MyVPC2"
  }
},
//Security Group with inbound and outbound rules (allow everything) allocated in (ports 80, 22, 443)
resource "aws_security_group" "webtraffic" {
  name = "Allow HTTPS"
  vpc_id = aws_vpc.MyVPC2.id
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    iterator = port
    for_each = var.egressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.MyVPC2.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Prod_subnet"
  }
}
//internet gateway associated to VPC2
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.MyVPC2.id 
  tags = {
    Name = "Gateway_VPC2"
  }
}
//route table for all resources to gw
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.MyVPC2.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "default route table"
  }
} 

//instance created in MyVPC  for the  Webserver
resource "aws_instance" "webserver" {
  count = "1"
  ami = "ami-06fd78dc2f0b69910"
  subnet_id = aws_subnet.subnet.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.id]
  key_name = "instancekey"
  
  tags = {
    Name = "Webserver"
  }	
}
//instance created in MyVPC  for the  Webserver
resource "aws_instance" "backend" {
  count = "1"
  ami = "ami-06fd78dc2f0b69910"
  subnet_id = aws_subnet.subnet.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.id]
  key_name = "instancekey"

  
  tags = {
    Name = "Backend"
  }	
}
//instance created in MyVPC  for the  Webserver
resource "aws_instance" "database" {
  count = "1"
  ami = "ami-06fd78dc2f0b69910"
  subnet_id = aws_subnet.subnet.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.id]
  key_name = "instancekey"
  
  tags = {
    Name = "Database"
  }	
}