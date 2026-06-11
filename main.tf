data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["proserv*tomcat*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["339712978510"] # 
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}