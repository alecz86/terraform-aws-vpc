# Create ALB
module "alb" {
  source                           = "terraform-aws-modules/alb/aws"
  version                          = "~> 8.0"
  name                             = "my-alb"
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.public_subnets

  security_groups = [
    aws_security_group.alb-sg.id
  ]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}


# ALB Security Group
resource "aws_security_group" "alb-sg" {
  description = "ALB Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id


 # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Route 53 CNAME record pointing ALB to blog.example.com

resource "aws_route53_record" "www" {
  zone_id = "Z031535353A87956940A"
  name    = "www.caramans.com"
  type    = "CNAME"
  ttl     = 300
  records = [module.alb.lb_dns_name]
}

