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

output "ebs_vol1" {
  description = "volume id"
  value       = join("",aws_ebs_volume.this.*.id)
}

output "ebs_vol2" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol2.*.id)
}

output "ebs_vol3" {
  description = "volume id"
  value       = join("",aws_ebs_volume.vol3.*.id)
}

output "ebs_vol4" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol4.*.id)
}

output "ebs_vol5" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol5.*.id)
}

output "ebs_vol6" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol6.*.id)
}

output "ebs_vol7" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol7.*.id)
}

output "ebs_vol8" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol8.*.id)
}

output "ebs_vol9" {
  description = "volume id"
  value       = join("", aws_ebs_volume.vol9.*.id)
}
