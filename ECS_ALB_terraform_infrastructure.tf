


# Define your provider
provider "aws" {
  region = "......." # 
}

# Create a VPC 
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16" 
  
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# Create a public subnets for the ALB
resource "aws_subnet" "ecs_subnet_1" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.0.0/24" 
  availability_zone = "....."  
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24" 
  availability_zone = "....."  


# Create a security group for the ALB
resource "aws_security_group" "ecs_alb_sg" {
  vpc_id = aws_vpc.ecs_vpc.id

  # Define inbound and outbound rules for the security group
  # Customize it for what specific need you have 

  # Inbound rules
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Outbound rules
  egress {
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
# You can add additional inbound and outbound rules as required


# Create the ALB
resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb" # Enter a name for your ALB
  internal           = false      # Set to true if you want an internal ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]

  # Customize other ALB options as needed
}

# Create a target group for your ECS service
resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-tg"
  port     = 80       
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs_vpc.id

  # Customize other target group options as needed
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster" # Enter a name for your cluster

  # Customize other ECS cluster options as needed
}

# Create a launch template for the ECS instances
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-lt"                
  image_id      = "ami-082af980f9f5514f8" 
  instance_type = "t2.micro"              

  # Customize other launch template options as needed
}

# Create an autoscaling group for the ECS instances
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-asg"                                               
  desired_capacity    = 2                                                        
  min_size            = 2                                                        
  max_size            = 4                                                       
  vpc_zone_identifier = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id] 
  target_group_arns   = [aws_lb_target_group.ecs_tg.arn]                         

  # Launch Template Configuration
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id 
    version = "$Latest"                                  
  }

  # Customize other autoscaling group options as needed
}
