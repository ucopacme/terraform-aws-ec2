# terraform-aws-ec2
Terraform AWS EC2 Module


-->

Terraform module to provision AWS [`EC2`]



## Introduction

The module will create:

* EC2 Instance


## Usage
Create terragrunt.hcl config file, copy/past the following configuration.

## Operating system selection

|Operating system|
|----------------|
| amazon         |
| amazon2        |
| centos7        | 
| centos8        |
| rhel6          |
| rhel7          |
| rhel8          |
| ubuntu1804     |
| ubuntu1810     |
| ubuntu1904     |
| windows2019    |
| windows2016    |
| windows2012r2  |


```hcl

#
# Include all settings from root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# make sure you deploy the security group before creating ec2 instance, ec2 instance depends on the security group.

# dependency "sg" {
#   config_path = "../sg"
# }
inputs = {
  enabled                = true       # change it to false to destory the ec2 instance
  os                     = "rhel7"    # List of os(amazon,amazon2,centos7,centos8,rhel6,rhel7,rhel8,ubuntu1804,ubuntu1810,ubuntu1904,windows2019,windows2016,windows2012r2)
  instance_type          = "t2.micro" # Default type is t2.micro
  subnet_id              = "subnet-xxxxxxxxx"
  vpc_security_group_ids = [dependency.sg.outputs.id]
  key_name               = "key"
  root_volume_size       = 50    # Default size is 100GB
  root_volume_encryption = true  # Default is true, Change it to False to create unencrypted root volume
  volume_type            = "gp3" # Default type is gp3
  enabled_ebs_volume1    = false # Default is false, change it to true to add ebs volume 1 (device_name = "/dev/sdh")
  ebs_volume1_size       = 10    # Default null
  enabled_ebs_volume2    = false  # Default is false, change it to true to add ebs volume 2 (device_name = "/dev/sdf")
  ebs_volume2_size       = 10    # Default null
  enabled_ebs_volume3    = false  # Default is false, change it to true to add ebs volume 3 (device_name = "/dev/sdj")
  ebs_volume3_size       = 10    # Default null
  enabled_ebs_volume4    = false  # Default is false, change it to true to add ebs volume 4 (device_name = "/dev/sdi")
  ebs_volume4_size       = 10    # Default null
  enabled_ebs_volume5    = false  # Default is false, change it to true to add ebs volume 5 (device_name = "/dev/sdk")
  ebs_volume5_size       = 10    # Default null
  tags = {
    "ucop:application" = "test"
    "ucop:createdBy"   = "terraform"
    "ucop:enviroment"  = "Prod"
    "ucop:group"       = "test"
    "ucop:source"      = join("/", ["https://github.com/ucopacme/ucop-terraform-config/tree/master/terraform/its-chs-dev/us-west-2", path_relative_to_include()])
    "Name"             = "test-kk-1"
    "ucop:owner"       = "chs"
  }
}

terraform {
  source = "git::https://git@github.com/ucopacme/terraform-aws-ec2.git//?ref=v0.0.13"
}