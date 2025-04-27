provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "this" {
  name = "demo-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "demo-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = jsonencode([{
    name      = "demo-container"
    image     = "<YOUR_ECR_IMAGE_URL>"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_ecs_service" "this" {
  name            = "demo-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["<SUBNET-ID-HERE>"]
    security_groups  = ["<SECURITY-GROUP-ID-HERE>"]
    assign_public_ip = true
  }

  desired_count = 1
}
