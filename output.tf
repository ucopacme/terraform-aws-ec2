# All resource-derived outputs are null when var.enabled is false.

output "instance_name" {
  description = "Value of the Name tag, or null if tags has no Name key"
  value       = lookup(var.tags, "Name", null)
}

output "instance_id" {
  description = "Instance ID"
  value       = one(aws_instance.this[*].id)
}

output "instance_arn" {
  description = "Instance ARN"
  value       = one(aws_instance.this[*].arn)
}

output "instance_type" {
  description = "Instance type in use, whether set directly via instance_type or auto-selected from vcpu_count/memory_gb"
  value       = one(aws_instance.this[*].instance_type)
}

output "ami" {
  description = "AMI ID the instance was launched from, whether set directly via ami or auto-selected via os. Because ami is in ignore_changes, this can differ from the current lookup result."
  value       = one(aws_instance.this[*].ami)
}

output "availability_zone" {
  description = "Availability zone the instance is in"
  value       = one(aws_instance.this[*].availability_zone)
}

output "instance_public_ip" {
  description = "Public IP assigned by AWS at launch (associate_public_ip_address). For an Elastic IP use eip_public_ip."
  value       = one(aws_instance.this[*].public_ip)
}

output "instance_private_ip" {
  description = "Primary private IP"
  value       = one(aws_instance.this[*].private_ip)
}

output "instance_private_dns" {
  description = "Private DNS name"
  value       = one(aws_instance.this[*].private_dns)
}

output "eip_public_ip" {
  description = "Elastic IP address, or null if enabled_eip is false"
  value       = one(aws_eip.this[*].public_ip)
}

output "network_interface_id" {
  description = "ID of the instance's primary network interface (existing, module-created, or AWS default ENI)"
  value       = one(aws_instance.this[*].primary_network_interface_id)
}

output "ebs_vol1" {
  description = "Volume ID of EBS volume 1 (/dev/sdh), or null if not enabled"
  value       = one(aws_ebs_volume.this[*].id)
}

output "ebs_vol2" {
  description = "Volume ID of EBS volume 2 (/dev/sdf), or null if not enabled"
  value       = one(aws_ebs_volume.vol2[*].id)
}

output "ebs_vol3" {
  description = "Volume ID of EBS volume 3 (/dev/sdj), or null if not enabled"
  value       = one(aws_ebs_volume.vol3[*].id)
}

output "ebs_vol4" {
  description = "Volume ID of EBS volume 4 (/dev/sdi), or null if not enabled"
  value       = one(aws_ebs_volume.vol4[*].id)
}

output "ebs_vol5" {
  description = "Volume ID of EBS volume 5 (/dev/sdk), or null if not enabled"
  value       = one(aws_ebs_volume.vol5[*].id)
}

output "ebs_vol6" {
  description = "Volume ID of EBS volume 6 (/dev/sdl), or null if not enabled"
  value       = one(aws_ebs_volume.vol6[*].id)
}

output "ebs_vol7" {
  description = "Volume ID of EBS volume 7 (/dev/sdm), or null if not enabled"
  value       = one(aws_ebs_volume.vol7[*].id)
}

output "ebs_vol8" {
  description = "Volume ID of EBS volume 8 (/dev/sdn), or null if not enabled"
  value       = one(aws_ebs_volume.vol8[*].id)
}

output "ebs_vol9" {
  description = "Volume ID of EBS volume 9 (/dev/sdo), or null if not enabled"
  value       = one(aws_ebs_volume.vol9[*].id)
}
