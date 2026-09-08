provider "aws" {
  region = "us-east-1"
}   

data "aws_ami_ids" "exampleami" {
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


variable "server_port" {
  description = "The port on which the server will listen"
  type        = number
  
}


resource "aws_instance" "example" {
  ami           = data.aws_ami_ids.exampleami.ids[0]
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
    #!/bin/bash
    # 1. Create the directory
    mkdir -p /var/www/html
    
    # 2. Write the HTML file
    echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
    
    # 3. Start busybox and point it to the directory using -h
    nohup busybox httpd -f -p ${var.server_port} -h /var/www/html &
    EOF
  user_data_replace_on_change = true


  tags = {
    Name = "ExampleInstance"
    Version = "1.0"
    Environment = "Development"
  }
  lifecycle {
  create_before_destroy = true
}
}

resource "aws_security_group" "instance" {
  name        = "example-security-group"
  description = "Allow HTTP 8080 traffic"

 
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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


output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the EC2 "
}