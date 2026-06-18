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

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"
  name = "blog"

  vpc_id = module.blog_vpc.vpc_id
  
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

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "blog-alb"
  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets

  security_groups = [module.blog_sg.id]

  listeners = {
    blog_http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_arn = aws_lb_target_group.blog.arn
      }
    }
  }


  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "blog" {
  name     = "blog"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.blog_vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "blog" {
  target_group_arn = aws_lb_target_group.blog.arn
  target_id        = aws_instance.blog.id
  port             = 80
}

module "blog_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.2.1"

  name = "blog"

  min_size = 1
  max_size = 2

  vpc_zone_identifier = module.blog_vpc.public_subnets

  launch_template_name = "blog"
  security_groups      = [module.blog_sg.id]
  instance_type        = var.instance_type
  image_id             = data.aws_ami.app_ami.id

  traffic_source_attachments = {
    blog_alb = {
      traffic_source_identifier = aws_lb_target_group.blog.arn
    }
  }
}

