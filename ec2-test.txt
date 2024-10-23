# Instance EC2 dans le sous-réseau privé
resource "aws_instance" "private_instance" {
  ami                    = "ami-04a81a99f5ec58529"    
  instance_type          = "t2.micro"        # Choisissez le type d'instance désiré
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_subnet_sg.id]
  key_name = "mykey"  #mettre sa clé .pem , seulement si elle est en clair dans votre fichier
  tags = {
    Name = "private-instance"
  }

}
