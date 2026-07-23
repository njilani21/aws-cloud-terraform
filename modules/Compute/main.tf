############################################
# COMPUTE MODULE - Highly Available App Tier
# ALB + Auto Scaling Group across multiple AZs
############################################

# ---------------- Auto-lookup latest Amazon Linux 2023 AMI ----------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------- Application Load Balancer ----------------
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-ALB"
  }
}

# ---------------- Target Group ----------------
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-TG"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-TG"
  }
}

# ---------------- ALB Listener ----------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"



  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ---------------- User data: installs nginx and pulls the site from S3 ----------------
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Install nginx and the AWS CLI
    dnf install -y nginx awscli

    mkdir -p /usr/share/nginx/html

    # Pull the static site down from S3 into nginx's web root
    aws s3 sync s3://${aws_s3_bucket.website.id} /usr/share/nginx/html --delete

    # Simple health check endpoint for the ALB target group
    echo "OK" > /usr/share/nginx/html/health

    systemctl enable nginx
    systemctl restart nginx
  EOF
}

# ---------------- Launch Template ----------------
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-LT"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_website.name
  }

  metadata_options {
    http_tokens = "required" # enforce IMDSv2
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-LT"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------- Auto Scaling Group (spans all private subnets/AZs) ----------------
resource "aws_autoscaling_group" "app" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Spread instances evenly across AZs
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------- Auto Scaling Policies (target tracking on CPU) ----------------
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
