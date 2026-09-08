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



resource "aws_instance" "example" {
  ami           = data.aws_ami_ids.exampleami.ids[0]
  instance_type = "t2.medium"
  tags = {
    Name = "ExampleInstance"
    Version = "1.0"
    Environment = "Development"
  }
  lifecycle {
  create_before_destroy = true
}
}
