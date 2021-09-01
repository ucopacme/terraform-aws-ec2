locals {
  enabled = var.enabled == "true"
}

data "aws_ami" "search" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = "${lookup("${var.amis_os_map_regex}", "${var.os}")}"
  owners     = ["${length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, var.os) : var.amis_primary_owners}"]
}

resource "aws_instance" "this" {
  count                       = local.enabled ? 1 : 0
  ami                         = data.aws_ami.search.id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.aws_iam_instance_profile
  instance_type               = var.instance_type
  monitoring                  = var.monitoring
  subnet_id                   = var.subnet_id
  tags                        = var.tags
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.volume_type

  }
  lifecycle {
    ignore_changes = [ami]
  }

}


resource "aws_ebs_volume" "this" {
  count             = var.enabled_ebs_volume ? 1 : 0
  size              = var.ebs_volume_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]

}

resource "aws_volume_attachment" "this" {
  count       = var.enable_ebs_volume_attachment ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.*.id[0]
  instance_id = aws_instance.this.*.id[0]


}
