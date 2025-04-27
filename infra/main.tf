provider "aws" {
  region = "us-east-1" # You can change to your preferred region
}

resource "aws_ecr_repository" "python_app" {
  name = "python-app-repo"
}

resource "aws_ecs_cluster" "python_cluster" {
  name = "python-cluster"
}

resource "aws_ecs_task_definition" "python_task" {
  family                   = "python-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name      = "python-app"
    image     = "${aws_ecr_repository.python_app.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "python_service" {
  name            = "python-app-service"
  cluster         = aws_ecs_cluster.python_cluster.id
  task_definition = aws_ecs_task_definition.python_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-xxxxxxx"] # You need to update this with your subnet id
    assign_public_ip = true
  }
}
