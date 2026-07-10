terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu-server"{
  ami = "ami-0f8a61b66d1accaee" # Example AMI ID for ubuntu server in us-east-1
  instance_type = "t3.micro"
}

