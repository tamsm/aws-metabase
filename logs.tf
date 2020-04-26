// CloudWatch group and log stream; retain logs for 30 days
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${var.project}"
  retention_in_days = 30

  tags = {
    Name = var.project
    Env = var.env
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = var.project
  log_group_name = aws_cloudwatch_log_group.logs.name
}