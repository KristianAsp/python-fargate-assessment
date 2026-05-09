terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state files in Terraform Cloud for consistency
  backend "remote" {
    organization = "kristian-aspevik"

    workspaces {
      name = "perk-assessment-deployment"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = "kriasp-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]
}

# --- Security groups ---
resource "aws_security_group" "alb" {
  name   = "kriasp-hello-alb"
  vpc_id = data.aws_vpc.default_vpc.id

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

resource "aws_security_group" "ecs_tasks" {
  name   = "kriasp-hello-ecs-tasks"
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Load balancer ---
resource "aws_lb" "main" {
  name               = "kriasp-hello-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.subnets.ids
}

resource "aws_lb_target_group" "main" {
  name        = "kriasp-hello-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default_vpc.id

  deregistration_delay = 30

  health_check {
    path = "/__mon/health"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "main" {
  family                   = "kriasp-hello"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.task_ecs.arn

  container_definitions = jsonencode([
    {
      name      = "hello"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# --- ECS Service ---
resource "aws_ecs_service" "main" {
  name            = "kriasp-hello"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count          = 2
  launch_type            = "FARGATE"
  # Terraform Apply should wait until the service reaches a steady state e.g. successful deployment
  wait_for_steady_state  = true

  network_configuration {
    subnets          = data.aws_subnets.subnets.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    # Public IP needed in order to pull Docker images without an ECR endpoint
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "hello"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}

# --- Outputs ---
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}
