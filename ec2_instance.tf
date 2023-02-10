resource "aws_instance" "web" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  #count         = 3
  key_name  = aws_key_pair.key.key_name
  subnet_id = aws_subnet.my_subnet.id
  //security_groups             = aws_security_group.my_security_group.name
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  user_data              = <<-EOF
              #!/bin/bash
              apt update
              apt upgrade -y
              apt install install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF

  tags = {
    Name       = "Amaury"
    managed_by = "terraform"
  }
}

resource "aws_security_group" "my_security_group" {
  name   = "security_group_terraform"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    //description      = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "aws-key"
  public_key = file("./aws-key.pub")

  tags = {
    Name       = "my-key-aws"
    managed_by = "terraform"
  }
}