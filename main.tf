data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*tomcat*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["345002264488"] # 
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}