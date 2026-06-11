resource "aws_instance" "web" {
  ami           = "ami-010b33ad04f5ea5e7"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}