output "instance_name" {
description = "The tag name for this instance"
value = var.tags.Name
}
output "instance_id" {
  description = "Instance ID"
  value       = join("", aws_instance.this.*.id)
}
output "instance_arn" {
  description = "Instance ID"
  value       = join("", aws_instance.this.*.arn)
}
output "instance_public_ip" {
  description = "Instance ip"
  value       = join("", aws_instance.this.*.public_ip)
}
output "instance_private_ip" {
  description = "Instance ip"
  value       = join("", aws_instance.this.*.private_ip)
}

