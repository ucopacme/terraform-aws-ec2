terraform {
  # 1.2: lifecycle preconditions on data.aws_subnet.subnet.
  required_version = ">= 1.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.0: primary_network_interface block on aws_instance.
      version = ">= 6.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }
  }
}
