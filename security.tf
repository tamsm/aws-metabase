// Security groups
// lb
resource "aws_security_group" "lb" {
  name        = "${var.project}-sg-alb"
  description = "Allows 443 inbound route & All outgoing"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// ECS task allows all outgoing, only 3000TCP incoming via ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-sg-ecs-task"
  description = "Allow inbound route from the ALB & All outgoing"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }
  egress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
