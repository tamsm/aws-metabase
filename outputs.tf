output "ecr_repo" {
  value = aws_ecr_repository.metabase.name
}
output "alb_public_dns" {
  description = "Goto:"
  value = "http://${aws_alb.metabase.dns_name}"
}