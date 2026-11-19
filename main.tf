locals {
  existing_eni = var.network_interface_id != null
  # count must not depend on network_interface_id: it may be unknown at plan time
  # when the ENI is created in the same apply. The precondition on
  # data.aws_subnet.subnet rejects setting both variables.
  create_eni = var.secondary_private_ips > 0
  eni_mode   = local.existing_eni || local.create_eni
  primary_eni_id = local.existing_eni ? var.network_interface_id : one(aws_network_interface.this[*].id)
}

resource "aws_network_interface" "this" {
  count             = local.enabled && local.create_eni ? 1 : 0
  subnet_id         = var.subnet_id
  security_groups   = var.vpc_security_group_ids
  private_ips_count = var.secondary_private_ips
  tags              = var.tags
}

# user_data including a base value for given var.os, and also var.user_data.
# (Note Cloud-init is applicable only for Linux).
data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false
  dynamic "part" {
    for_each = [
      contains(keys(var.base_user_data), var.os) ? var.base_user_data[var.os] : "",
      var.user_data
    ]
    content {
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }
}

# Read in ID of common security group created by Firewall Manager.
data "aws_subnet" "subnet" {
  id = var.subnet_id

  # Cross-variable checks live here because this data source is always
  # evaluated (no count), even when var.enabled is false. Variable validation
  # can't reference other variables before Terraform 1.9.
  lifecycle {
    precondition {
      condition     = var.subnet_id != null && var.subnet_id != ""
      error_message = "subnet_id is required."
    }
    precondition {
      condition     = !(var.network_interface_id != null && var.secondary_private_ips > 0)
      error_message = "network_interface_id and secondary_private_ips cannot both be set. Assign secondary IPs on the existing network interface instead."
    }
  }
}

data "aws_security_groups" "fms_security_groups_common_usw2" {
  tags = {
    fms-policy-name = "security_groups_common_usw2"
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.subnet.vpc_id]
  }
}

locals {
  enabled = var.enabled == true
  # Null-safe so a bad vcpu_count/memory_gb pair reaches the precondition on
  # aws_instance.this (clear error) instead of failing inside coalesce()/min().
  vcpu_count = var.vcpu_count != null ? var.vcpu_count : (
    var.memory_gb != null ? try(min([for k, v in var.ec2_instance_map : k if contains(keys(v), tostring(var.memory_gb))]...), null) : 2
  )
  memory_gb = var.memory_gb != null ? var.memory_gb : (
    var.vcpu_count != null ? try(min(keys(lookup(var.ec2_instance_map, var.vcpu_count, {}))...), null) : 1
  )
  instance_type = var.instance_type != null && var.instance_type != "" ? var.instance_type : (
    try(var.ec2_instance_map[tostring(local.vcpu_count)][tostring(local.memory_gb)], null)
  )

  # Valid pairs for the error message, sorted numerically, e.g.
  # "2 vCPU: 1/2/4/8/16 GB; 4 vCPU: 8/16/32 GB; ..."
  valid_instance_sizes = join("; ", [
    for c in sort([for k in keys(var.ec2_instance_map) : format("%05d", tonumber(k))]) :
    "${tonumber(c)} vCPU: ${join("/", [
      for m in sort([for k in keys(var.ec2_instance_map[tostring(tonumber(c))]) : format("%05d", tonumber(k))]) : tonumber(m)
    ])} GB"
  ])

  # If var.raw_user_data was provided, use that for user_data.
  # Else if non-Windows, use cloudinit_config user_data (see above).
  # Otherwise (for Windows), use var.user_data if defined, else var.base_user_data.
  # (Ideal to-do: find a way to do merged var.user_data and base_user_data on Windows).
  is_windows = length(regexall("^(windows|customwin)", var.os)) > 0
  user_data = var.raw_user_data != "" ? var.raw_user_data : (
    !local.is_windows ? data.cloudinit_config.this.rendered : (
      (contains(keys(var.base_user_data), var.os) && var.user_data == "") ? var.base_user_data[var.os] : var.user_data
    )
  )
}

# Only search when var.ami isn't set, so an explicit ami doesn't depend on var.os.
data "aws_ami" "search" {
  count              = var.ami == null || var.ami == "" ? 1 : 0
  most_recent        = true
  include_deprecated = contains(["ol8", "ol9"], var.os) ? true : false

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Defaults avoid a raw lookup() error; the precondition below reports it clearly.
  name_regex = lookup(var.amis_os_map_regex, var.os, null)
  owners     = length(var.amis_primary_owners) > 0 ? var.amis_primary_owners : [lookup(var.amis_os_map_owners, var.os, "self")]

  lifecycle {
    precondition {
      condition = contains(keys(var.amis_os_map_regex), var.os) && (
        length(var.amis_primary_owners) > 0 || contains(keys(var.amis_os_map_owners), var.os)
      )
      error_message = "var.os \"${var.os}\" has no entry in amis_os_map_regex/amis_os_map_owners. Use a supported os, add map entries, or set var.ami."
    }
  }
}


# resource block for ec2 #
resource "aws_instance" "this" {
  count                       = local.enabled ? 1 : 0
  ami                         = var.ami != null && var.ami != "" ? var.ami : one(data.aws_ami.search[*].id)
  associate_public_ip_address = local.eni_mode ? null : var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.instance_profile
  instance_type               = local.instance_type
  monitoring                  = var.monitoring
  subnet_id                   = local.eni_mode ? null : var.subnet_id
  tags                        = var.tags
  vpc_security_group_ids      = local.eni_mode ? null : concat(var.vpc_security_group_ids, data.aws_security_groups.fms_security_groups_common_usw2.ids)
  key_name                    = var.key_name
  user_data                   = local.user_data
  # Use new primary_network_interface for ENI
  dynamic "primary_network_interface" {
    for_each = local.eni_mode ? [1] : []
    content {
      network_interface_id = local.primary_eni_id
    }
  }
  cpu_options {
    core_count       = var.core_count
    threads_per_core = var.threads_per_core
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.volume_type
    encrypted   = var.root_volume_encryption
    iops        = contains(["gp3", "io1", "io2"], var.volume_type) ? var.root_volume_iops : null
    throughput  = contains(["gp3"], var.volume_type) ? var.root_volume_throughput : null
    tags        = var.tags
  }
  lifecycle {
    precondition {
      condition     = local.instance_type != null
      error_message = "No instance type for vcpu_count = ${coalesce(var.vcpu_count, "(not set)")}, memory_gb = ${coalesce(var.memory_gb, "(not set)")} in ec2_instance_map. Valid pairs: ${local.valid_instance_sizes}. Or set instance_type directly."
    }
    # ignore_changes = [ami,ebs_block_device,root_block_device,associate_public_ip_address]
    ignore_changes = [tags["ResourceGroup"],tags["ucop:AWSPatchPolicy"],root_block_device[0].tags["ucop:prePatchEbsSnapshot"],ami,associate_public_ip_address,user_data]
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = var.metadata_http_tokens
    instance_metadata_tags      = var.instance_metadata_tags
  }
}


# resource block for eip #
resource "aws_eip" "this" {
  count    = local.enabled && var.enabled_eip ? 1 : 0
  domain   = "vpc"
  tags     = var.tags
}

# resource block for ec2 and eip association #
resource "aws_eip_association" "eip_assoc" {
  count    = local.enabled && var.enabled_eip ? 1 : 0
  instance_id   = one(aws_instance.this[*].id)
  allocation_id = one(aws_eip.this[*].id)

}
# resource block for ebs volumes #
resource "aws_ebs_volume" "this" {
  count             = local.enabled && var.enabled_ebs_volume1 ? 1 : 0
  size              = var.ebs_volume1_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume1_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume1_throughput : null
  snapshot_id       = var.snapshot_id_volume1
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "this" {
  count       = local.enabled && var.enabled_ebs_volume1 ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = one(aws_ebs_volume.this[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol2" {
  count             = local.enabled && var.enabled_ebs_volume2 ? 1 : 0
  size              = var.ebs_volume2_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume2_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume2_throughput : null
  snapshot_id       = var.snapshot_id_volume2
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment2" {
  count       = local.enabled && var.enabled_ebs_volume2 ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = one(aws_ebs_volume.vol2[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol3" {
  count             = local.enabled && var.enabled_ebs_volume3 ? 1 : 0
  size              = var.ebs_volume3_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume3_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume3_throughput : null
  snapshot_id       = var.snapshot_id_volume3
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment3" {
  count       = local.enabled && var.enabled_ebs_volume3 ? 1 : 0
  device_name = "/dev/sdj"
  volume_id   = one(aws_ebs_volume.vol3[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol4" {
  count             = local.enabled && var.enabled_ebs_volume4 ? 1 : 0
  size              = var.ebs_volume4_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume4_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume4_throughput : null
  snapshot_id       = var.snapshot_id_volume4
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment4" {
  count       = local.enabled && var.enabled_ebs_volume4 ? 1 : 0
  device_name = "/dev/sdi"
  volume_id   = one(aws_ebs_volume.vol4[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol5" {
  count             = local.enabled && var.enabled_ebs_volume5 ? 1 : 0
  size              = var.ebs_volume5_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume5_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume5_throughput : null
  snapshot_id       = var.snapshot_id_volume5
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment5" {
  count       = local.enabled && var.enabled_ebs_volume5 ? 1 : 0
  device_name = "/dev/sdk"
  volume_id   = one(aws_ebs_volume.vol5[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol6" {
  count             = local.enabled && var.enabled_ebs_volume6 ? 1 : 0
  size              = var.ebs_volume6_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume6_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume6_throughput : null
  snapshot_id       = var.snapshot_id_volume6
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment6" {
  count       = local.enabled && var.enabled_ebs_volume6 ? 1 : 0
  device_name = "/dev/sdl"
  volume_id   = one(aws_ebs_volume.vol6[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol7" {
  count             = local.enabled && var.enabled_ebs_volume7 ? 1 : 0
  size              = var.ebs_volume7_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume7_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume7_throughput : null
  snapshot_id       = var.snapshot_id_volume7
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment7" {
  count       = local.enabled && var.enabled_ebs_volume7 ? 1 : 0
  device_name = "/dev/sdm"
  volume_id   = one(aws_ebs_volume.vol7[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol8" {
  count             = local.enabled && var.enabled_ebs_volume8 ? 1 : 0
  size              = var.ebs_volume8_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume8_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume8_throughput : null
  snapshot_id       = var.snapshot_id_volume8
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment8" {
  count       = local.enabled && var.enabled_ebs_volume8 ? 1 : 0
  device_name = "/dev/sdn"
  volume_id   = one(aws_ebs_volume.vol8[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}

resource "aws_ebs_volume" "vol9" {
  count             = local.enabled && var.enabled_ebs_volume9 ? 1 : 0
  size              = var.ebs_volume9_size
  type              = var.volume_type
  iops              = contains(["gp3", "io1", "io2"], var.volume_type) ? var.ebs_volume9_iops : null
  throughput        = contains(["gp3"], var.volume_type) ? var.ebs_volume9_throughput : null
  snapshot_id       = var.snapshot_id_volume9
  availability_zone = one(aws_instance.this[*].availability_zone)
  tags                        = var.tags
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "attachment9" {
  count       = local.enabled && var.enabled_ebs_volume9 ? 1 : 0
  device_name = "/dev/sdo"
  volume_id   = one(aws_ebs_volume.vol9[*].id)
  instance_id = one(aws_instance.this[*].id)
  lifecycle {
    ignore_changes = [instance_id,volume_id]
  }
}
