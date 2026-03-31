locals {
  image_properties_map = {
      "ubuntu22" = {
            source_image_marketplace_sku = "canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2"
            aws_source_ami_owner        = "837727238323"
            aws_source_ami_name_patterns = {
                  "x86_64" = "ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*"
                  "arm64"  = "ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-arm64-server-*"
            }
            os_disk_size_gb = 75
      },
      "ubuntu24" = {
            source_image_marketplace_sku = "canonical:ubuntu-24_04-lts:server"
            aws_source_ami_owner        = "837727238323"
            aws_source_ami_name_patterns = {
                  "x86_64" = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
                  "arm64"  = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"
            }
            os_disk_size_gb = 75
      }
  }

  source_image_marketplace_sku = local.image_properties_map[var.image_os].source_image_marketplace_sku
  aws_source_ami_name_pattern = local.image_properties_map[var.image_os].aws_source_ami_name_patterns[var.aws_architecture]
  aws_source_ami_owner        = local.image_properties_map[var.image_os].aws_source_ami_owner
  os_disk_size_gb = coalesce(var.os_disk_size_gb, local.image_properties_map[var.image_os].os_disk_size_gb)
}
