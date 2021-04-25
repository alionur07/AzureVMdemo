output "aws_instance_id" {
  value = aws_instance.sentry.id
}

output "aws_instance_public_ip" {
  value = aws_instance.sentry.public_ip
}

output "aws_instance_public_dns" {
  value = aws_instance.sentry.public_dns
}
