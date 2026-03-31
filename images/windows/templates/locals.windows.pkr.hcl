locals {
    image_properties_map = {
      "win22" = {
            source_image_marketplace_sku = "MicrosoftWindowsServer:WindowsServer:2022-Datacenter-g2"
            aws_source_ami_name_pattern = "Windows_Server-2022-English-Full-Base-*"
            aws_source_ami_owner        = "amazon"
            os_disk_size_gb = 256
      },
      "win25" = {
            source_image_marketplace_sku = "MicrosoftWindowsServer:WindowsServer:2025-Datacenter-g2"
            aws_source_ami_name_pattern = "Windows_Server-2025-English-Full-Base-*"
            aws_source_ami_owner        = "amazon"
            os_disk_size_gb = 150
      },
      "win25-vs2026" = {
            source_image_marketplace_sku = "MicrosoftWindowsServer:WindowsServer:2025-Datacenter-g2"
            aws_source_ami_name_pattern = "Windows_Server-2025-English-Full-Base-*"
            aws_source_ami_owner        = "amazon"
            os_disk_size_gb = 150
      }
  }

  source_image_marketplace_sku = local.image_properties_map[var.image_os].source_image_marketplace_sku
  aws_source_ami_name_pattern = local.image_properties_map[var.image_os].aws_source_ami_name_pattern
  aws_source_ami_owner        = local.image_properties_map[var.image_os].aws_source_ami_owner
  os_disk_size_gb = coalesce(var.os_disk_size_gb, local.image_properties_map[var.image_os].os_disk_size_gb)
}
