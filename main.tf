resource "aws_instance" "web" {
  ami           = "ami-06f48941d83036ff9"
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}