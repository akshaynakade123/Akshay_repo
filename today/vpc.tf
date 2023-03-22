#https://hiveit.co.uk/techshop/terraform-aws-vpc-example/03-create-an-rds-db-instance/


#create vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "150.50.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Main"
  }
}

#Create an internet gateway to give our subnet access to the outside world:
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-example-internet-gateway"
  }
}

#Create subnets in each availability zone to launch our instances into, each with address blocks within the VPC:
#frontend id
resource "aws_subnet" "frontend_subnet_1" {
 # count                   = length(var.subnet_var)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "150.50.0.1/20"
  availability_zone       = var.az_var[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "frontend_subnet_1"
  }
}

resource "aws_subnet" "frontend_subnet_2" {
  #count                   = length(var.subnet_var)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "150.50.16.1/24"
  availability_zone       = var.az_var[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "frontend_subnet_2"
  }
}

resource "aws_subnet" "frontend_subnet_3" {
  #count                   = length(var.subnet_var)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "150.50.32.1/24"
  availability_zone       = var.az_var[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "frontend_subnet_3"
  }
}



#Grant the VPC internet access on its main route table:
resource "aws_route_table" "example_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "main_route_table"
  }
}

# subnet associate with route
resource "aws_route_table_association" "associate_1" {
  #count          = length(var.subnet_var)
  subnet_id      = ["aws_subnet.frontend_subnet_1", "aws_subnet.frontend_subnet_2" , "aws_subnet.frontend_subnet_3"]
  route_table_id = aws_route_table.example_public.id
}

#associate inetrnet gateway with route table
resource "aws_route_table_association" "associate_2" {
  gateway_id     = aws_internet_gateway.my_igw.id
  route_table_id = aws_route_table.example_public.id

}

#create vpc secuity group
resource "aws_security_group" "my_sp_sg" {
  name        = "new_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "var.tag_1"
  }
}


#Create a new application load balancer:
resource "aws_lb" "alb" {
  name                       = "terraform-example-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.my_sp_sg.id]
  subnets                    = aws_subnet.frontend_subnet_1.*.id
  enable_deletion_protection = false

  /* tags = {
    Environment = "production"
  } */
}


#Create a new target group for the application load balancer.
resource "aws_lb_target_group" "tg_grp_alb" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  /* stickiness {
    type = "lb_cookie"
  } */
  #Stickiness The type of stickiness associated with this target group. If enabled, 
  #the load balancer binds a client’s session to a specific instance within the target group.

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/index.html"
    port = 80
  }
}

#Create two new application load balancer listeners. The first listener is configured to accept HTTP client connections.
resource "aws_lb_listener" "front_end_simple" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_grp_alb.arn
  }
}

#Create a new target group for the application load balancer.
resource "aws_lb_target_group" "tg_grp_alb_mob" {
  name     = "tf-example-lb-tg-mob"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  /* stickiness {
    type = "lb_cookie"
  } */
  #Stickiness The type of stickiness associated with this target group. If enabled, 
  #the load balancer binds a client’s session to a specific instance within the target group.

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/mob/index.html"
    port = 80
  }
}



/* Create two new application load balancer listeners. The first listener is configured to accept HTTP client connections.
resource "aws_lb_listener" "front_end-mob" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_grp_alb_mob.arn
  }
} */
#Create a new target group for the application load balancer.
resource "aws_lb_target_group" "tg_grp_alb_tab" {
  name     = "tf-example-lb-tg-tab"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  #Stickiness The type of stickiness associated with this target group. If enabled, 
  #the load balancer binds a client’s session to a specific instance within the target group.
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/tab/index.html"
    port = 80
  }
}
/* Create two new application load balancer listeners. The first listener is configured to accept HTTP client connections.
resource "aws_lb_listener" "front_end_tab_1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_grp_alb_tab.arn
  }
} */

# Forward action

resource "aws_lb_listener_rule" "host_based_weighted_routing_mob" {
  listener_arn = aws_lb_listener.front_end_simple.arn
  priority     = 9

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_grp_alb_mob.arn
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

resource "aws_lb_listener_rule" "host_based_weighted_routing_tab" {
  listener_arn = aws_lb_listener.front_end_simple.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_grp_alb_tab.arn
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "chabi" {
  key_name   = "terraform_chabi"
  public_key = tls_private_key.rsa-4096-example.public_key_openssh
}


resource "aws_launch_configuration" "as_conf" {
  name_prefix     = "terraform-lc-example-"
  image_id        = "ami-052efd3df9dad4825"
  instance_type   = "t2.micro"
  user_data       = "${file("install_apache.sh")}"
  security_groups = [aws_security_group.my_sp_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "as_conf_tab" {
  name_prefix     = "terraform-lc-example-"
  image_id        = "ami-052efd3df9dad4825"
  instance_type   = "t2.micro"
  user_data       = "${file("tab_page.sh")}"
  security_groups = [aws_security_group.my_sp_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "as_conf_mob" {
  name_prefix     = "terraform-lc-example-"
  image_id        = "ami-052efd3df9dad4825"
  instance_type   = "t2.micro"
  user_data       = "${file("mob_page.sh")}"
  security_groups = [aws_security_group.my_sp_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  vpc_zone_identifier  = aws_subnet.frontend_subnet_1.*.id
  min_size             = 2
  max_size             = 4

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.as_conf.id
  min_size             = 2
  max_size             = 4
  target_group_arns    = ["${aws_lb_target_group.tg_grp_alb.arn}"]
  vpc_zone_identifier  = aws_subnet.frontend_subnet_1.*.id

  tag {
    key                 = "Name"
    value               = "terraform-example-autoscaling-group"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group_mob" {
  launch_configuration = aws_launch_configuration.as_conf.id
  min_size             = 2
  max_size             = 4
  target_group_arns    = ["${aws_lb_target_group.tg_grp_alb_mob.arn}"]
  vpc_zone_identifier  = aws_subnet.frontend_subnet_1.*.id

  tag {
    key                 = "Name"
    value               = "terraform-example-autoscaling-group_mob"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group_tab" {
  launch_configuration = aws_launch_configuration.as_conf.id
  min_size             = 2
  max_size             = 4
  target_group_arns    = ["${aws_lb_target_group.tg_grp_alb_tab.arn}"]
  vpc_zone_identifier  = aws_subnet.frontend_subnet_1.*.id

  tag {
    key                 = "Name"
    value               = "terraform-example-autoscaling-group_tab"
    propagate_at_launch = true
  }
}

