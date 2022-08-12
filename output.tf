# Get name of ALB after deployment
output "loadbalancer-name" {
  description = "DNS name of ALB"
  value       = aws_lb.ext-alb.dns_name

}
