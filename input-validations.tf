/*
    IBM Spectrum scale cloud deployment validation.

    1. Resource Group
    2. Region and zone
    3. Profile
    4. Key
    5. Image
    6. Scale Parameters
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group
}

data "ibm_is_region" "itself" {
  name = var.vpc_region
}

data "ibm_is_zones" "itself" {
  region = var.vpc_region
}

locals {
  validate_vpc_availability_zones_cnd = length(setsubtract(var.vpc_availability_zones, data.ibm_is_zones.itself.zones))
  vpc_availability_zones_msg          = "Specified input list for vpc_availability_zones is not valid."
  validate_vpc_availability_zones_chk = regex("^${local.vpc_availability_zones_msg}$", (local.validate_vpc_availability_zones_cnd == 0 ? local.vpc_availability_zones_msg : ""))
}

locals {
  validate_zone                  = var.storage_type == "persistent" ? contains(["us-south-1", "us-south-3", "eu-de-1", "eu-de-2"], join(",", var.vpc_availability_zones)) : true
  zone_msg                       = "The solution supports bare metal server creation in only given availability zones i.e. us-south-1, us-south-3, eu-de-1, and eu-de-2. To deploy persistent storage provide any one of the supported availability zones."
  validate_persistent_region_chk = regex("^${local.zone_msg}$", (local.validate_zone ? local.zone_msg : ""))
}

locals {
  icn_cnd = (var.storage_type != "evaluation" && var.ibm_customer_number == null) || (var.storage_type != "evaluation" && var.ibm_customer_number == "") ? false : true
  icn_msg = "The IBM customer number input value can't be empty."
  icn_chk = regex("^${local.icn_msg}$", (local.icn_cnd ? local.icn_msg : ""))
}

data "ibm_is_instance_profile" "bastion" {
  name   = var.bastion_vsi_profile
}

data "ibm_is_instance_profile" "bootstrap" {
  name   = var.bootstrap_vsi_profile
}

data "ibm_is_instance_profile" "compute_vsi" {
  name   = var.compute_vsi_profile
}

data "ibm_is_instance_profile" "storage_vsi" {
  name   = var.storage_vsi_profile
  count  = var.storage_type != "persistent" ? 1 : 0
}

data "ibm_is_bare_metal_server_profile" "storage_bare_metal_server" {
  name   = var.storage_bare_metal_server_profile
  count  = var.storage_type == "persistent" ? 1 : 0
}

data "ibm_is_ssh_key" "bastion_ssh_key" {
  name = var.bastion_key_pair
}

data "ibm_is_ssh_key" "compute_ssh_key" {
  name = var.compute_cluster_key_pair
}

data "ibm_is_ssh_key" "storage_ssh_key" {
  name = var.storage_cluster_key_pair
}

data "ibm_is_image" "bastion_image" {
  name = var.bastion_osimage_name
}

locals {
  // Validate Bastion os image.
  bastion_os              = split("-", data.ibm_is_image.bastion_image.os)[0]
  validate_bastion_os     = local.bastion_os == "ubuntu"
  validate_bastion_os_msg = "Error: Invalid custom image name. The solution currently supports only ubuntu stock images of any version available on that region."
  validate_bastion_os_chk = regex(
    "^${local.validate_bastion_os_msg}$",
    ( local.validate_bastion_os
    ? local.validate_bastion_os_msg
    : "" ) )
}

locals {
  // Check whether an entry is found in the mapping file for the given bootstrap node image
  bootstrap_image_mapping_entry_found = contains(keys(local.bootstrap_image_region_map), var.bootstrap_osimage_name)
  bootstrap_image_id                  = local.bootstrap_image_mapping_entry_found ? lookup(lookup(local.bootstrap_image_region_map, var.bootstrap_osimage_name), var.vpc_region) : "Image not found with the given name"

  // Check whether an entry is found in the mapping file for the given compute node image
  compute_image_mapping_entry_found = contains(keys(local.compute_image_region_map), var.compute_vsi_osimage_name)
  compute_image_id                  = var.storage_type == "evaluation" && !(local.compute_image_mapping_entry_found) ? lookup(lookup(local.evaluation_image_region_map, one(keys(local.evaluation_image_region_map))), var.vpc_region) : local.compute_image_mapping_entry_found ? lookup(lookup(local.compute_image_region_map, var.compute_vsi_osimage_name), var.vpc_region) : data.ibm_is_image.compute_image[0].id
  compute_osimage_name              = var.storage_type == "evaluation" && !(local.compute_image_mapping_entry_found) ? one(keys(local.evaluation_image_region_map)) : local.compute_image_mapping_entry_found ? var.compute_vsi_osimage_name : data.ibm_is_image.compute_image[0].name

  // Check whether an entry is found in the mapping file for the given storage node image
  storage_image_mapping_entry_found = contains(keys(local.storage_image_region_map), var.storage_vsi_osimage_name)
  storage_image_id                  = var.storage_type == "evaluation" ? lookup(lookup(local.evaluation_image_region_map, one(keys(local.evaluation_image_region_map))), var.vpc_region) : local.storage_image_mapping_entry_found ? lookup(lookup(local.storage_image_region_map, var.storage_vsi_osimage_name), var.vpc_region) : data.ibm_is_image.storage_image[0].id
  storage_osimage_name              = var.storage_type == "evaluation" ? one(keys(local.evaluation_image_region_map)) : local.storage_image_mapping_entry_found ? var.storage_vsi_osimage_name : data.ibm_is_image.storage_image[0].name
}

data "ibm_is_image" "bootstrap_image" {
  name  = var.bootstrap_osimage_name
  count = local.bootstrap_image_mapping_entry_found ? 0 : 1
}

data "ibm_is_image" "compute_image" {
  name  = var.compute_vsi_osimage_name
  count = local.compute_image_mapping_entry_found ? 0 : 1
}

data "ibm_is_image" "storage_image" {
  name  = var.storage_vsi_osimage_name
  count = var.storage_type != "persistent" && local.storage_image_mapping_entry_found ? 0 : 1
}

data "ibm_is_image" "bare_metal_image" {
  name  = var.storage_bare_metal_osimage_name
#  count = var.storage_type == "persistent" ? 1 : 0
}

locals {
  // Validate the total storage count for the total_storage_cluster_instance variable, as this validation is not possible to be done on Variables decided to validate this during the apply plan process. For both persistent and scratch type the validation happens at main.tf directly
  validate_total_storage_cluster_instances_cnd = var.storage_type == "persistent" ? var.total_storage_cluster_instances >= 3 && var.total_storage_cluster_instances <= 10 : var.total_storage_cluster_instances >= 3 && var.total_storage_cluster_instances <= 18
  total_storage_cluster_instances_msg          = "Specified input \"total_storage_cluster_instances\" must be in between the range of 3 and 10 while storage type is persistent otherwise it should be in range of 3 and 18.Please provide the appropriate range of value."
  validate_total_storage_cluster_instances_chk = regex("^${local.total_storage_cluster_instances_msg}$", ((local.validate_total_storage_cluster_instances_cnd ? local.total_storage_cluster_instances_msg : "") ))
}

locals {
  validate_storage_gui_username_cnd = (length(var.storage_cluster_gui_username) >= 4 && length(var.storage_cluster_gui_username) <= 32 && trimspace(var.storage_cluster_gui_username) != "")
  storage_gui_username_msg                = "Specified input for \"storage_cluster_gui_username\" is not valid.username should be greater or equal to 4 letters."
  validate_storage_gui_username_chk       = regex("^${local.storage_gui_username_msg}$", (local.validate_storage_gui_username_cnd ? local.storage_gui_username_msg : ""))

  validate_compute_gui_username_cnd = (length(var.compute_cluster_gui_username) >= 4 && length(var.compute_cluster_gui_username) <= 32 && trimspace(var.compute_cluster_gui_username) != "")
  compute_gui_username_msg          = "Specified input for \"compute_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  validate_compute_gui_username_chk = regex("^${local.compute_gui_username_msg}$", (local.validate_compute_gui_username_cnd ? local.compute_gui_username_msg : ""))

  validate_storage_gui_password_cnd = (replace(lower(var.storage_cluster_gui_password), lower(var.storage_cluster_gui_username), "") == lower(var.storage_cluster_gui_password))
  storage_gui_password_msg                  = "Storage cluster GUI password should not contain username."
  validate_storage_gui_password_chk = regex("^${local.storage_gui_password_msg}$", (local.validate_storage_gui_password_cnd ? local.storage_gui_password_msg : ""))

  validate_compute_gui_password_cnd = (replace(lower(var.compute_cluster_gui_password), lower(var.compute_cluster_gui_username), "") == lower(var.compute_cluster_gui_password))
  compute_gui_password_msg                  = "Compute cluster GUI password should not contain username."
  validate_compute_gui_password_chk = regex("^${local.compute_gui_password_msg}$", (local.validate_compute_gui_password_cnd ? local.compute_gui_password_msg : ""))
}

locals {
  total_storage_capacity      = var.storage_type == "evaluation" ? data.ibm_is_instance_profile.storage_vsi[0].disks[0].quantity[0].value * data.ibm_is_instance_profile.storage_vsi[0].disks[0].size[0].value * var.total_storage_cluster_instances : 0
  evaluation_storage_type_cnd = var.storage_type == "evaluation" && local.total_storage_capacity > 12000 ? false : true
  evaluation_storage_type_msg = "The evaluation storage type supports 12TB storage capacity."
  evaluation_storage_type_chk = regex("^${local.evaluation_storage_type_msg}$", (local.evaluation_storage_type_cnd ? local.evaluation_storage_type_msg : ""))
}
