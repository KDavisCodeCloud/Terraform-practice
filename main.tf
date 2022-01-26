# Configure the AWS Provider and the region
provider "aws" {
  region  = "us-east-1"
    access_key = "my-access-key" #showing set up. hiding keys (not best practice to have them displayed here)
  secret_key = "my-secret-key"  #showing set up. hiding keys (not best practice to have them displayed here)
}

# you would create a vpc here. Your own "private cloud". Its a security measure. "example" is to name vpc whatever you want. 
# Specific tag for naming vpc is similar to the "tags" example a few lines down. 
resource "aws_vpc" "example" {
 cidr_block = "10.0.0.0/16"

}
 tags {
     Name = "Production"
 }

 #create vpc subnet. naming convention for vpc is "aws_vpc.example". Its name of vpc resource followed by a "dot" with the name of the vpc ("example")

resource "aws_subnet" "First_subnet" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-Subnet"
  }
}
# Configure the resource (in this case an EC2 resource). in "web", give it a name. Its the name of your EC2 instance.data " "name" 
# Look in the aws console for the AMI id that you will use (linux, ubuntu, redhat, fedora, docker image, etc.)

resource "aws_instance" "First_cmdline_instance_Terraform" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"


#use a tag in the event that you want to identify a certain instance or search or an instance, etc. "special tag for naming a resource"

  tags = {
    Name = "FirstInstance"
  }
}
#quick demo of the following: 

# 1. Create a vpc

resource "aws_vpc" "prod-vpc" {
 cidr_block = "10.0.0.0/16"

}
 tags {
     Name = "Prod"
 }
# 2. Create Internet Gateway
resource "aws_internet_gateway" "prodgw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "Prod-gateway"
  }
}

# 3. Create Custom Route Table

resource "aws_route_table" "ProdRoute" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.prodgw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.prodgw.id
  }

  tags = {
    Name = "Prod-Route"
  }
}
# 4. Create a subnet

resource "aws_subnet" "Prod-subnet" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-Subnet"
  }
}

# 5. Associate subnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Prod-subnet.id
  route_table_id = aws_route_table.ProdRoute.id
}
# 6. Create Security Group to allow port 22, 80, 443

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.prod-vpc.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.prod-vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
# 7. Create a Network Interface with an ip in the subnet that was created in step 4. 


# 8. Assign an elastic IP to the network interface created in step 7. 
# 9. Create Ubuntu Server and install/ enable apache2









# in a production envirionment, you will be performing "terraform apply" to make changes as needed quite often. 
#terraform destroy will delete entire infrasfructure. You won't use this often but the option is there
#terraform plan is to check your existing code to see if if will work and if terraform sees any issues with your code. 
#terraform init command to initiate instance
#terraform state command shows list of subcommands