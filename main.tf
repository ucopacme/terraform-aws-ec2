locals {
  enabled = var.enabled == "true"
}

resource "aws_instance" "this" {
  count                       = local.enabled ? 1 : 0
  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.aws_iam_instance_profile
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  tags                        = var.tags
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.volume_type

  }

}


resource "aws_ebs_volume" "this" {
  size = 2
  availability_zone = aws_instance.this.*.availability_zone
  
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.this[count.index].id
  instance_id = aws_instance.this.id[count.index]

  
}
