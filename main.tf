provider "aws" {
  region                   = "us-east-1"
}

# terraform {
#   backend "s3" {
#     bucket                  = "terraform-backend-lepro"
#     key                     = "Lepro-dev.tfstate"
#     region                  = "us-east-1"
#   }
# }

# Création du VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Création du sous-réseau public
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Création du sous-réseau privé
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
   availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet"
  }
}

# Création de l'Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

# Création de la NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "my-nat-gw"
  }
}

# Table de routage publique
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Association de la table de routage publique au sous-réseau public
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Table de routage privée
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Association de la table de routage privée au sous-réseau privé
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


# Création du sg
module "sg" {
  source = "./modules/sg"
  vpc_id        = aws_vpc.my_vpc.id
}

# Création de l'EIP
module "eip" {
  source = "./modules/eip"
}

# Création de l'EC2
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.small"
  public_ip     = module.eip.output_eip
  sg_id       = module.sg.output_sg_id
  subnet_id     = aws_subnet.public_subnet.id
  server_name   = "public_server"

}

module "priv_ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.small"
  #public_ip     = module.eip.output_eip
  sg_id       = module.sg.output_sg_id
  subnet_id     = aws_subnet.private_subnet.id
  server_name   = "private_server"

}
#Creation des associations nécessaires
resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2.output_ec2_id
  allocation_id = module.eip.output_eip_id
}
