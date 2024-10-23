resource "aws_instance" "ic-webapp-ec2" {
  ami               = "ami-0e86e20dae9224db8"
  instance_type     = var.instance_type
  subnet_id              = var.subnet_id
  key_name          = var.ssh_key
  availability_zone = var.AZ
  vpc_security_group_ids = [var.sg_id]
 # security_groups   = ["${var.sg_name}"]
  tags = {
    Name = "${var.server_name}-ec2"
  }

  root_block_device {
    delete_on_termination = true
  }


}

