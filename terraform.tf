terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
}


# Create a VPC
resource "aws_vpc" "proj-vpc" {
  cidr_block = "10.0.0.0/16"
}

#Create a Gateway
resource "aws_internet_gateway" "proj-ig" {
  vpc_id = aws_vpc.proj-vpc.id

  tags = {
    Name = "gateway1"
  }
}

# Setting up the routing table
resource "aws_route_table" "proj-rt" {
  vpc_id = aws_vpc.proj-vpc.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj-ig.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.proj-ig.id
  }

  tags = {
    Name = "rt1"
  }
}


#Create Subnet
resource "aws_subnet" "proj-subnet" {
  vpc_id     = aws_vpc.proj-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone= "eu-north-1b"
  tags = {
    Name = "subnet1"
  }
}

#associate the subnet with the route table
resource "aws_route_table_association" "proj-rt-sub-assoc" {
        subnet_id = aws_subnet.proj-subnet.id
        route_table_id = aws_route_table.proj-rt.id
}




# Create Scurity Groups
resource "aws_security_group" "proj-sg" {
  name        = "proj-sg"
  description = "enable traffic on port 22,80 and 443"
  vpc_id      = aws_vpc.proj-vpc.id

  ingress {
    description      = "All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "proj-sg1"
  }
}




#Create Network interfaces
resource "aws_network_interface" "proj-ni" {
  subnet_id       = aws_subnet.proj-subnet.id
  private_ips     = ["10.0.1.14"]
  security_groups = [aws_security_group.proj-sg.id]
}

#Creating Elastic IP
resource "aws_eip" "proj-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.proj-ni.id
  associate_with_private_ip = "10.0.1.14"
}


#Creating Ec2 instance
resource "aws_instance" "proj-instance" {
  ami           = "ami-0989fb15ce71ba39e" # eu-north-1
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "raju"

  network_interface {
    network_interface_id = aws_network_interface.proj-ni.id
    device_index         = 0
  }
  

  tags = {
      Name = "prod-server"
  }
}
