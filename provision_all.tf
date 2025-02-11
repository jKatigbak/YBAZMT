# TODO separate into different tf files
provider "aws" {
    region  = var.region_name
}
variable "region_name" {
  description = "Region"
  default = "us-west-2"
}
variable "username" {
  description = "ssh user"
  default = "ubuntu"
}
variable "script_path" {
  description = "Where is the path to the script locally on the machine?"
  default = "./bootstrap.sh"
}

variable "private_key_path" {
  description = "The path to the private key used to connect to the instance"
  default = "~/.ssh/terraform.priv"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default = "10.1.0.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default = "us-west-2a"
}
variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/terraform.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-0cb3ad465c8fd14dd"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "Test"
}
variable "source_ip" {
  description = "Environment tag"
  default = "38.99.102.20/32"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
           Environment = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
   tags = {
           Environment = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone
  tags = {
           Environment = var.environment_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
   tags = {
           Environment = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id

}

resource "aws_security_group" "allow_all_from_source" {
  name = "alllow_all_from_source"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
      var.source_ip
    ]
  }
}

resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.source_ip
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
    tags = {
           Environment = var.environment_tag
   }

}
resource "aws_key_pair" "ec2key" {
  key_name = "terraform.pub"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "caddyserver" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet_public.id
  vpc_security_group_ids = [
    aws_security_group.sg_22.id, aws_security_group.allow_all_from_source.id
  ]
  key_name = aws_key_pair.ec2key.key_name

  provisioner "file" {
    source      = "./src"
    destination = "/tmp"

    connection {
      type = "ssh"
      user = var.username
      host = aws_instance.caddyserver.public_ip
      private_key = file(var.private_key_path)
    }
  }
    provisioner "file" {
    source      = "./bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type = "ssh"
      user = var.username
      host = aws_instance.caddyserver.public_ip
      private_key = file(var.private_key_path)
    }
  }

  provisioner "remote-exec" {

    inline = [
          "chmod +x /tmp/bootstrap.sh",
          "/tmp/bootstrap.sh",
          "sudo make -C /tmp/src build",
          "nohup sudo make -C /tmp/src run",
          "sleep 2" // prevent terraform from closing the connection before process starts
    ]

    connection {
      type = "ssh"
      user = var.username
      host = aws_instance.caddyserver.public_ip
      private_key = file(var.private_key_path)
    }
  }
}




