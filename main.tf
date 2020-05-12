// ECS resources
// Defined in the topological order:
// CLUSTER -> SERVICE -> TASK -> CONTAINER

resource "aws_ecs_cluster" "main" {
  name = var.project
}

// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
resource "aws_ecs_service" "main" {
  name             = var.project
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.metabase.arn
  desired_count    = var.app_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.metabase.arn
    container_name   = var.project
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end_ssl]
}


// https://github.com/aws-samples/aws-containers-task-definitions
resource "aws_ecs_task_definition" "metabase" {
  family                   = var.project
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task.arn
  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.metabase.repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "${var.project}",
    "networkMode": "awsvpc",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.project}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 32000,
        "hardLimit": 32000
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecr_repository" "metabase" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
