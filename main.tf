resource "aws_instance" "web" {
  ami           = "ami-0304b89296c6f0dc2"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}