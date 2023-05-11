
#Feel free to make changes, comment, I'm eager to learn ;)


# Define your provider
provider "aws" {
  region = "eu-west-1" # Enter your desired AWS region
}

# Create a VPC 
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16" # Enter your desired VPC CIDR block
  # Customize other VPC options as needed
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# Create a public subnets for the ALB
resource "aws_subnet" "ecs_subnet_1" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.0.0/24" # Enter your desired subnet CIDR block(That's an example, you can change it)
  availability_zone = "eu-west-1a"  # Enter your desired availability zone(That's an example, you can change it)
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24" # Enter your desired subnet CIDR block for subnet 2(That's an example, you can change it)
  availability_zone = "eu-west-1b"  # Enter your desired availability zone for subnet 2(That's an example, you can change it)
}


# Create a security group for the ALB
resource "aws_security_group" "ecs_alb_sg" {
  vpc_id = aws_vpc.ecs_vpc.id

  # Define inbound and outbound rules for the security group
  # Customize it for what specific need you have 

  # Inbound rules
  ingress {
    from_port   = 80 # Allow incoming HTTP traffic
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow access from any source (you can restrict it to specific IP ranges if you need it)
  }

  # Outbound rules
  egress {
    from_port   = 0 # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow access to any destination (you can restrict it to specific IP ranges if needed)
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
  name     = "ecs-tg" # Enter a name for your target group
  port     = 80       # Enter the port your service listens on
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
  name_prefix   = "ecs-lt"                # Enter a name prefix for your launch template
  image_id      = "ami-082af980f9f5514f8" # Enter the ID of your desired ECS optimized AMI
  instance_type = "t2.micro"              # Enter your desired instance type

  # Customize other launch template options as needed
}

# Create an autoscaling group for the ECS instances
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-asg"                                                # Enter a name for your autoscaling group
  desired_capacity    = 2                                                        # Enter your desired number of instances
  min_size            = 2                                                        # Enter your minimum number of instances
  max_size            = 4                                                        # Enter your maximum number of instances
  vpc_zone_identifier = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id] # Enter the subnet ID(s) where instances should be launched
  target_group_arns   = [aws_lb_target_group.ecs_tg.arn]                         # Specify the ARN of the target group(s) for the instances

  # Launch Template Configuration
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id # Specify the ID of the launch template
    version = "$Latest"                                  # Use the latest version of the launch template
  }

  # Customize other autoscaling group options as needed
}
