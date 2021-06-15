output "instance_id" {
  description = "Instance ID"
  value       = join("", aws_instance.this.*.id)
}

output "profile_name" {
  description = "IAM Instance Profile"
  value       = join("", aws_iam_instance_profile.this.*.name)

}