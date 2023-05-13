terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.65.0"
    }
  }      
}
provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws_vpc"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aws_vpn_gateway"
  }
}



