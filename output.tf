output "instance_id" {
  description = "Instance ID"
  value       = join("", aws_instance.this.*.id)
}

