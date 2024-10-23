# Groupe de sécurité pour le sous-réseau public
resource "aws_security_group" "public_subnet_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "public-sg"
  tags = {
    Name = "public-sg"
  }

  # Autoriser le trafic entrant HTTP, HTTPS et SSH depuis n'importe où
  #idéalement choisir une source, soit une plage d'ip voir une seul ip.
  #Ou un port précis.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  # Autoriser tout le trafic sortant
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
    }
}