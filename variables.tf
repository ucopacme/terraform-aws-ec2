variable "ami" {
  description = "Amazon Machine Image"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  default     = true
  description = "(Optional) Associate a public ip address with an instance in a VPC. Boolean value."
  type        = bool
}

# variable "desc_sg" {
#   description = "security group description"
#   type        = string
# }

variable "enabled" {
  type        = string
  description = "Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

variable "enabled_ebs_volume" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "enable_ebs_volume_attachment" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = true
}


variable "instance_type" {
  default     = "t2.micro"
  description = "instance_type"
  type        = string
}

variable "name_ec2" {
  description = "ec2 name"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet Id"
  type        = string
  default     = ""
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
  default     = ""
}


variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 100
}

variable "ebs_volume_size" {
type = number
description = "size of ebs volume"
default = 50
}

variable "volume_type" {
  type = string
  description = "volume_type"
  default = "gp3"
}

variable "role_name" {
  type    = string
  default = ""

}

variable "key_name" {
  type = string
  description = "EC2 key"
  default = ""
}

variable "vpc_security_group_ids" {
  type = list(string)
  description = "(optional) describe your variable"
  default = []
}

variable "aws_iam_instance_profile" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
