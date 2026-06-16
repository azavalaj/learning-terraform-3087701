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

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.id]

  tags = {
    Name = "Blog"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"
  name = "blog"

  vpc_id = data.aws_vpc.default.id
  
  ingress_rules = {
    http-80-tcp = {
      from_port   = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTP from anywhere"
    }

    https-443-tcp = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTPS from anywhere"
    }
  }

  egress_rules = {
    all-all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "out to anywhere"
    }
  }

}