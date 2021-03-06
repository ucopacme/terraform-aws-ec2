variable "ami" {
  description = "Amazon Machine Image"
  type        = string
  default     = "amazon2"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "associate_public_ip_address" {
  default     = false
  description = "(Optional) Associate a public ip address with an instance in a VPC. Boolean value."
  type        = bool
}

variable "enabled_eip" {
  default     = false
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

variable "root_volume_encryption" {
  type        = bool
  description = "Set to `false` to prevent encyption"
  default     = true
}
variable "enabled_ebs_volume1" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = false
}
variable "enabled_ebs_volume2" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = false
}
variable "enabled_ebs_volume3" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = false
}
variable "enabled_ebs_volume4" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = false
}
variable "enabled_ebs_volume5" {
  type        = bool
  description = "Set to `false` to prevent the module from creating any resources"
  default     = false
}

# variable "enable_ebs_volume1_attachment" {
#   type        = bool
#   description = "Set to `false` to prevent the module from creating any resources"
#   default     = false
# }
# variable "enable_ebs_volume2_attachment" {
#   type        = bool
#   description = "Set to `false` to prevent the module from creating any resources"
#   default     = false
# }


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

variable "ebs_volume1_size" {
  type        = number
  description = "size of ebs volume"
  default     = null
}
variable "ebs_volume2_size" {
  type        = number
  description = "size of ebs volume"
  default     = null
}
variable "ebs_volume3_size" {
  type        = number
  description = "size of ebs volume"
  default     = null
}
variable "ebs_volume4_size" {
  type        = number
  description = "size of ebs volume"
  default     = null
}
variable "ebs_volume5_size" {
  type        = number
  description = "size of ebs volume"
  default     = null
}

variable "volume_type" {
  type        = string
  description = "volume_type"
  default     = "gp3"
}

variable "role_name" {
  type    = string
  default = ""

}

variable "key_name" {
  type        = string
  description = "EC2 key"
  default     = ""
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "(optional) describe your variable"
  default     = null
}

variable "instance_profile" {
  type        = string
  description = "(optional) describe your variable"
  default     = null
}

variable "ebs_optimized" {
  type        = bool
  default     = false
  description = "If true, the launched EC2 instance will be EBS-optimized."
}

variable "monitoring" {
  type        = bool
  default     = false
  description = "If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)."
}

variable "disable_api_termination" {
  type        = bool
  default     = false
  description = "If true, enables EC2 Instance Termination Protection."
}
variable "user_data" {
  type        = string
  default     = ""
  description = "(Optional) A string of the desired User Data for the ec2."
}

# AMI search

variable "os" {
  description = "The Os reference to search for"
  # default     = ""
}

variable "amis_primary_owners" {
  description = "Force the ami Owner, could be (self) or specific (id)"
  default     = ""
}

variable "amis_os_map_regex" {
  description = "Map of regex to search amis"
  type        = map

  default = {
    ubuntu1804        = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*"
    ubuntu1810        = "^ubuntu/images/hvm-ssd/ubuntu-cosmic-18.10-amd64-server-.*"
    ubuntu1904        = "^ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-.*"
    centos7           = "CentOS.Linux.7.*x86_64.*"
    centos8           = "CentOS.Linux.8.*x86_64.*"
    rhel6             = "^RHEL-6.*x86_64.*"
    rhel7             = "^RHEL-7.*x86_64.*"
    rhel8             = "^RHEL-8.*x86_64.*"
    amazon2           = "^amzn2-ami-hvm-.*x86_64-gp2"
    windows2019       = "^Windows_Server-2019-English-Full-Base-.*"
    windows2016       = "^Windows_Server-2016-English-Full-Base-.*"
    windows2012r2     = "^Windows_Server-2012-R2_RTM-English-64Bit-Base-.*"
    customlinux       = "custom-linux-ami*"
    customwin         = "custom-win-ami*"
    customrhel7       = "custom-rhel7-ami*"
  }
}

variable "amis_os_map_owners" {
  description = "Map of amis owner to filter only official amis"
  type        = map
  default = {
    ubuntu1804    = "099720109477" #CANONICAL
    ubuntu1810    = "099720109477" #CANONICAL
    ubuntu1904    = "099720109477" #CANONICAL
    rhel6         = "309956199498" #Amazon Web Services
    rhel7         = "309956199498" #Amazon Web Services
    rhel8         = "309956199498" #Amazon Web Services
    centos7       = "679593333241"
    centos8       = "679593333241"
    amazon        = "137112412989" #amazon
    amazon2       = "137112412989" #amazon
    windows2019   = "801119661308" #amazon
    windows2016   = "801119661308" #amazon
    windows2012r2 = "801119661308" #amazon
    customlinux   = "self"
    customwin     = "self"
    customrhel7   = "self"
  }
}

