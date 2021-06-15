# terraform-aws-ec2
Terraform AWS EC2 Module


-->

Terraform module to provision AWS [`EC2`]



## Introduction

The module will create:

* EC2 Instance



## Usage
Create terragrunt.hcl config file and past the following configuration.


#
# Include all settings from root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "sg" {
  config_path = "../sg"
}

inputs = {
  enabled                = false
  ami                    = "ami-0800fc0fa715fdcfe"
  instance_type          = "t2.micro" # Default type is t2.micro
  subnet_id              = "subnet-084c56f1fd8699780"
  vpc_security_group_ids = [dependency.sg.outputs.id]
  key_name               = "my-Key"
  volume_size            = 50 # Default size is 100GB
  volume_type            = "gp2" # Default type is gp3

  tags = {
    "ucop:application" = "test"
    "ucop:createdBy"   = "terraform"
    "ucop:enviroment"  = "Prod"
    "ucop:group"       = "test"
    "ucop:source"      = join("/", ["https://github.com/ucopacme/ucop-terraform-config/tree/master/terraform/its-chs-dev/us-west-2", path_relative_to_include()])
    "Name"             = "test"
  
  }

}


terraform {
  source = "git::https://git@github.com/ucopacme/terraform-aws-ec2.git?ref=v0.0.1"

}
