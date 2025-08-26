# terraform-aws-ec2
Terraform AWS EC2 Module


-->

Terraform module to provision AWS [`EC2`]



## Introduction

The module will create:

* EC2 Instance


## Usage
1. Create main.tf config file, copy/paste and customize the following configuration.

## Operating system selection

|Operating system|
|--------------------|
| al2023             |
| rhel8              |
| rhel9              |
| ubuntu1804         |
| ubuntu1810         |
| ubuntu1904         |
| windows2022        |
| windows2019        |
| windows2019SQL2016E|
| windows2016        |
| customlinux        |
| customwin          |

The os variable is used to auto-select an appropriate latest Amazon Machine Image (ami) corresponding to the OS.

For cases requiring a certain ami, provide a specific value for the ami variable.  This will preclude any values provided for the os variable, which will be ignored.

## Instance type and size selection

Specifying values for vcpu\_count and memory\_gb will auto-select a preferred instance type and size.  If a value for only one of these two variables is provided, the minimum possible value will be used for the other (example: setting memory\_gb = 1 without providing a value for vcpu\_count will implicitly set vcpu\_count to 2, corresponding to 2 vCPU, 1 GB memory micro size).

Note that not all vcpu\_count and memory\_gb combinations are valid.  For example, there is not an instance type with 16 vCPUs and 1 GB memory.

For cases requiring a certain instance type, provide a specific value for the instance\_type variable.  This will preclude any values provided for vcpu\_count or memory\_gb, which will be ignored.

```hcl

#
#

# make sure you deploy the security group before creating ec2 instance, ec2 instance depends on the security group.



provider "aws" {
  region = "us-west-2"
}

module "ec2" {
  source = "git::https://git@github.com/ucopacme/terraform-aws-ec2.git//?ref=v0.0.33"
  enabled                = true     # change it to false to destroy the ec2 instance
  os                     = "al2023" # List of os(al2023,amazon2,rhel7,rhel8,rhel9,ubuntu1804,ubuntu1810,ubuntu1904,windows2019,windows2016,windows2019SQL2016E)
  vcpu_count             = 2        # Choices are 2,4,8,16,32
  memory_gb              = 4        # Choices are 1,2,4,8,16,32,64,128,256
  core_count             = ""       # default set to Null, Set customized CPU core count
  threads_per_core       = ""       # default set to Null, Set customized threads per core
  subnet_id              = "subnet_id"
  vpc_security_group_ids = "security_group_ids"
  root_volume_size       = 150   # Default size is 100GB
  root_volume_encryption = true  # Default is true, change it to false to create unencrypted root volume
  volume_type            = "gp3" # Default type is gp3
  enabled_eip            = false # Default is false, change it to true to add EIP
  enabled_ebs_volume1    = true  # Default is false, change it to true to add ebs volume 1 (device_name = "/dev/sdh")
  ebs_volume1_size       = 50    # Default null
  snapshot_id_volume1    = ""    # Default null
  enabled_ebs_volume2    = true  # Default is false, change it to true to add ebs volume 2 (device_name = "/dev/sdf")
  ebs_volume2_size       = 150   # Default null
  snapshot_id_volume2    = ""    # Default null
  enabled_ebs_volume3    = true  # Default is false, change it to true to add ebs volume 3 (device_name = "/dev/sdj")
  ebs_volume3_size       = 150   # Default null
  snapshot_id_volume3    = ""    # Default null
  enabled_ebs_volume4    = true  # Default is false, change it to true to add ebs volume 4 (device_name = "/dev/sdi")
  ebs_volume4_size       = 400   # Default null
  snapshot_id_volume4    = ""    # Default null
  enabled_ebs_volume5    = false # Default is false, change it to true to add ebs volume 5 (device_name = "/dev/sdk")
  ebs_volume5_size       = 10    # Default null
  snapshot_id_volume5    = ""    # Default null
  tags = {
    "ucop:application" = "xxx"
    "ucop:createdBy"   = "terraform"
    "ucop:environment" = "xxx"
    "ucop:group"       = "xxx"
    "ucop:source"      = "https://github.com/ucopacme/ucop-terraform-deployments/terraform/xxx/"
    "Name"             = "xxx"
    "ucop:owner"       = "xxx"
  }
}

2. (Optional) create outputs.tf config file, copy/paste the following configuration.

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


