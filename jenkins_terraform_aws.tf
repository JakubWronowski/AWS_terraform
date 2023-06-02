provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "jenkins-example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jenkins-example-vpc"
  }
}

resource "aws_subnet" "jenkins-example" {
  vpc_id     = aws_vpc.jenkins-example.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "jenkins_pub1"
  }
}

resource "aws_security_group" "jenkins-example" {
  name        = "jenkins-example-SG"
  description = "Jenkins Example Security Group"
  vpc_id      = aws_vpc.jenkins-example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "jenkins-example" {
  name = "jenkins-example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_instance" "jenkins-example" {
  count         = 2
  ami           = "ami-0e23c576dacf2e3df"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.jenkins-example.id

  vpc_security_group_ids = [aws_security_group.jenkins-example.id]
  key_name               = "jenkins-example.pem"

  iam_instance_profile = aws_iam_instance_profile.jenkins-example.name
  tags = {
    Name = "jenkins-example-instance"
  }
}

resource "aws_iam_instance_profile" "jenkins-example" {
  name = "jenkins-example"
  role = aws_iam_role.jenkins-example.name
}

