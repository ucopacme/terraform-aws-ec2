locals {
  enabled = var.enabled == "true"
}

data "aws_ami" "search" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = lookup(var.amis_os_map_regex, var.os)
  owners     = [length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, var.os) : var.amis_primary_owners]

}


# resource block for ec2 #
resource "aws_instance" "this" {
  count                       = local.enabled ? 1 : 0
  ami                         = data.aws_ami.search.id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.instance_profile
  instance_type               = var.instance_type
  monitoring                  = var.monitoring
  subnet_id                   = var.subnet_id
  tags                        = var.tags
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  user_data                   = var.user_data
  

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.volume_type
    encrypted   = var.root_volume_encryption
    tags        = var.tags

  }
  lifecycle {
    # ignore_changes = [ami,ebs_block_device,root_block_device,associate_public_ip_address]
    ignore_changes = [ami,ebs_block_device,associate_public_ip_address]
  }

}


# resource block for eip #
resource "aws_eip" "this" {
  count    = var.enabled_eip ? 1 : 0
  vpc      = true
  tags     = var.tags
}

# resource block for ec2 and eip association #
resource "aws_eip_association" "eip_assoc" {
  count    = var.enabled_eip ? 1 : 0
  instance_id   = aws_instance.this.*.id[0]
  allocation_id = aws_eip.this.*.id[0]
  
}
# resource block for ebs volumes #
resource "aws_ebs_volume" "this" {
  count             = var.enabled_ebs_volume1 ? 1 : 0
  size              = var.ebs_volume1_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }

}

resource "aws_volume_attachment" "this" {
  count       = var.enabled_ebs_volume1 ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.*.id[0]
  instance_id = aws_instance.this.*.id[0]
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }

}


resource "aws_ebs_volume" "vol2" {
  count             = var.enabled_ebs_volume2 ? 1 : 0
  size              = var.ebs_volume2_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }

}

resource "aws_volume_attachment" "attachment2" {
  count       = var.enabled_ebs_volume2 ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.vol2.*.id[0]
  instance_id = aws_instance.this.*.id[0]
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
  
}

resource "aws_ebs_volume" "vol3" {
  count             = var.enabled_ebs_volume2 ? 1 : 0
  size              = var.ebs_volume3_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }

}

resource "aws_volume_attachment" "attachment3" {
  count       = var.enabled_ebs_volume3 ? 1 : 0
  device_name = "/dev/sdj"
  volume_id   = aws_ebs_volume.vol3.*.id[0]
  instance_id = aws_instance.this.*.id[0]
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
  
}

resource "aws_ebs_volume" "vol4" {
  count             = var.enabled_ebs_volume4 ? 1 : 0
  size              = var.ebs_volume4_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
 

}

resource "aws_volume_attachment" "attachment4" {
  count       = var.enabled_ebs_volume4 ? 1 : 0
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.vol4.*.id[0]
  instance_id = aws_instance.this.*.id[0]
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
  
}

resource "aws_ebs_volume" "vol5" {
  count             = var.enabled_ebs_volume5 ? 1 : 0
  size              = var.ebs_volume5_size
  type              = var.volume_type
  availability_zone = aws_instance.this.*.availability_zone[0]
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }

}

resource "aws_volume_attachment" "attachment5" {
  count       = var.enabled_ebs_volume5 ? 1 : 0
  device_name = "/dev/sdk"
  volume_id   = aws_ebs_volume.vol5.*.id[0]
  instance_id = aws_instance.this.*.id[0]
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

