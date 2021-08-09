provider "aws" {
    region= "us-east-1"
    access_key = "AKIAXUHURZV7DI66S67H"
    secret_key = "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"
    
}
resource "aws_vpc" "First-vpc"{
    cidr_block ="10.0.0.0/16"
    tags={
        name ="VPC"
    }
}

resource "aws_subnet" "first-subnet" {
    vpc_id =aws_vpc.First-vpc.id
    cidr_block ="10.0.1.0/24"
    availability_zone="us-east-1a"
    tags={
        name ="SUBNET"
    }
}

resource "aws_internet_gateway" "first-gw"{
    vpc_id=aws_vpc.First-vpc.id
    tags={
        name="GW"
    }
}
resource "aws_route_table" "first-rt"{
    vpc_id=aws_vpc.First-vpc.id
    route{
         cidr_block="0.0.0.0/0"
         gateway_id=aws_internet_gateway.first-gw.id
    }
}
resource "aws_route_table_association" "First_association"{
    subnet_id=aws_subnet.first-subnet.id
    route_table_id=aws_route_table.first-rt.id
}

resource "aws_security_group" "First-secgrp" {
  name        = "allow_Web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.First-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SECGRP"
  }
}

resource "aws_network_interface" "first-NIC" {
  subnet_id       = aws_subnet.first-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.First-secgrp.id]

}
resource "aws_eip" "first-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.first-NIC.id
  associate_with_private_ip = "10.0.1.50"
  depends_on =[aws_internet_gateway.first-gw]

}
output "server_public_ip"{
    value = aws_eip.first-eip.public_ip
}
output "server_prv_ip"{
value=aws_eip.first-eip.private_ip
}

resource "aws_instance" "First_instance"{
    ami="ami-0c2b8ca1dad447f8a"
    instance_type="t2.micro"
    availability_zone ="us-east-1a"
    key_name ="unix_demo"
    network_interface{ 
        device_index = 0
        network_interface_id =aws_network_interface.first-NIC.id
    }
    user_data = <<-EOF
    sudo yum update -y
    sudo yum install httpd
    sudo service httpd start
    EOF
    tags={
        name="WEB_SERVER"
    }


}
