output "ecr_repo" {
  value = aws_ecr_repository.metabase.name
}
output "alb_public_dns" {
  description = "Goto:"
  value = "https://${aws_alb.metabase.dns_name}"
}
//output "route53_alb_alias" {
//  description = "OrGoto:"
//  value = "https://${aws_route53_record.load_balancer.fqdn}"
//}