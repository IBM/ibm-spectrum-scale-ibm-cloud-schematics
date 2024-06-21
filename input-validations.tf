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

locals {
  vpc_region = join("-", slice(split("-", var.vpc_availability_zones[0]), 0, 2))
}

data "ibm_is_region" "itself" {
  name = local.vpc_region
}

data "ibm_is_zones" "itself" {
  region = local.vpc_region
}

data "ibm_is_vpc" "existing_vpc" {
  count = var.vpc_name != null ? 1 : 0
  name  = var.vpc_name
}

data "ibm_is_vpc_address_prefixes" "vpc_cidr" {
  count = var.vpc_name != null ? 1 : 0
  vpc   = data.ibm_is_vpc.existing_vpc[0].id
}

data "ibm_is_subnet" "existing_vpc_subnets" {
  for_each   = var.vpc_name != null ? toset(data.ibm_is_vpc.existing_vpc[0].subnets[*].id) : toset([])
  identifier = each.value
}

#Finding existing public gateway attached for the VPC
locals {
  existing_vpc_crn = var.vpc_name != null ? data.ibm_is_vpc.existing_vpc[0].crn : null
  # Get the list of public gateways from the existing vpc on provided var.vpc_availability_zones input parameter. If no public gateway is found and in that zone our solution creates a new public gateway.
  existing_pgs                 = [for subnetsdetails in data.ibm_is_subnet.existing_vpc_subnets : subnetsdetails.public_gateway if subnetsdetails.zone == var.vpc_availability_zones[0] && subnetsdetails.public_gateway != ""]
  existing_public_gateway_zone = var.vpc_name == null ? "" : (length(local.existing_pgs) == 0 ? "" : element(local.existing_pgs, 0))
}

# Calculate the next available /24 or /18 CIDR blocks that don't overlap with existing subnets
# Calculate the next available /24 or /18 CIDR blocks that don't overlap with existing subnets
locals {
  existing_vpc_cidr      = var.vpc_name != null ? element(data.ibm_is_vpc_address_prefixes.vpc_cidr[0].address_prefixes[*].cidr, 0) : null
  existing_subnets_cidrs = [for s in data.ibm_is_subnet.existing_vpc_subnets : s.ipv4_cidr_block]
}

data "ibm_is_subnet" "existing_compute_subnet" {
  count = var.vpc_name != null && var.vpc_compute_subnet != null ? 1 : 0
  name  = var.vpc_compute_subnet
}

data "ibm_is_subnet" "existing_storage_subnet" {
  count = var.vpc_name != null && var.vpc_storage_subnet != null ? 1 : 0
  name  = var.vpc_storage_subnet
}

data "ibm_is_subnet" "existing_protocol_subnet" {
  count = var.vpc_name != null && var.vpc_protocol_subnet != null ? 1 : 0
  name  = var.vpc_protocol_subnet
}

locals {
  existing_compute_subnet_id  = var.vpc_name != null && var.vpc_compute_subnet != null ? data.ibm_is_subnet.existing_compute_subnet[0].id : null
  existing_storage_subnet_id  = var.vpc_name != null && var.vpc_storage_subnet != null ? data.ibm_is_subnet.existing_storage_subnet[0].id : null
  existing_protocol_subnet_id = var.vpc_name != null && var.vpc_protocol_subnet != null ? data.ibm_is_subnet.existing_protocol_subnet[0].id : null
}

###### DNS Resources for existing VPC

#dns_service
data "ibm_resource_instance" "existing_dns_resource_instance" {
  count             = var.vpc_dns_service_name != null ? 1 : 0
  name              = var.vpc_dns_service_name
  location          = "global"
  resource_group_id = data.ibm_resource_group.itself.id
  service           = "dns-svcs"
}

#dns_custom_resolver
data "ibm_dns_custom_resolvers" "existing_dns_custom_resolver_id" {
  count       = var.vpc_dns_custom_resolver_name != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
}

/*
#dns_zone

data "ibm_dns_zones" "existing_dns_zones" {
  count       = var.vpc_name != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
}

locals {
  existing_storage_dns_zone_id = var.vpc_dns_service_name != null ? element([for zone in data.ibm_dns_zones.existing_dns_zones[0].dns_zones : zone.zone_id if lower(zone.name) == lower(var.vpc_storage_cluster_dns_domain)], 0) : null

  existing_compute_dns_zone_id = var.vpc_dns_service_name != null ? element([for zone in data.ibm_dns_zones.existing_dns_zones[0].dns_zones : zone.zone_id if lower(zone.name) == lower(var.vpc_compute_cluster_dns_domain)],0) : null

  existing_gklm_dns_zone_id = var.scale_encryption_enabled == true && var.vpc_dns_service_name != null ? element([for zone in data.ibm_dns_zones.existing_dns_zones[0].dns_zones : zone.zone_id if lower(zone.name) == lower(var.scale_encryption_dns_domain)],0) : null

  existing_protocol_dns_zone_id = var.vpc_dns_service_name != null ? element([for zone in data.ibm_dns_zones.existing_dns_zones[0].dns_zones : zone.zone_id if lower(zone.name) == lower(var.vpc_protocol_cluster_dns_domain)],0) : null
  
  existing_client_dns_zone_id = var.vpc_dns_service_name != null ? element([for zone in data.ibm_dns_zones.existing_dns_zones[0].dns_zones : zone.zone_id if lower(zone.name) == lower(var.vpc_client_cluster_dns_domain)],0) : null
}

#dns_permitted_networks

data "ibm_dns_permitted_networks" "existing_storage_pm_ntw" {
  count       = var.vpc_name != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
  zone_id     = local.existing_storage_dns_zone_id
}

data "ibm_dns_permitted_networks" "existing_compute_pm_ntw" {
  count       = var.vpc_name != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
  zone_id     = local.existing_compute_dns_zone_id
}

data "ibm_dns_permitted_networks" "existing_gklm_pm_ntw" {
  count       = var.scale_encryption_enabled == true && var.vpc_name != null && local.existing_gklm_dns_zone_id != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
  zone_id     = local.existing_gklm_dns_zone_id
}

data "ibm_dns_permitted_networks" "existing_protocol_pm_ntw" {
  count       = local.scale_ces_enabled == true && var.vpc_name != null ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
  zone_id     = local.existing_protocol_dns_zone_id
}

data "ibm_dns_permitted_networks" "existing_client_pm_ntw" {
  count       = var.vpc_name != null && local.create_client_cluster == true ? 1 : 0
  instance_id = data.ibm_resource_instance.existing_dns_resource_instance[0].guid
  zone_id     = local.existing_client_dns_zone_id
}

locals {
  existing_storage_pm_ntw_id  = var.vpc_name != null ? (length(data.ibm_dns_permitted_networks.existing_storage_pm_ntw[0].dns_permitted_networks) > 0 ? tolist(data.ibm_dns_permitted_networks.existing_storage_pm_ntw[0].dns_permitted_networks[*].permitted_network_id)[0] : null) : null
  existing_compute_pm_ntw_id  = var.vpc_name != null ? (length(data.ibm_dns_permitted_networks.existing_compute_pm_ntw[0].dns_permitted_networks) > 0 ? tolist(data.ibm_dns_permitted_networks.existing_compute_pm_ntw[0].dns_permitted_networks[*].permitted_network_id)[0] : null) : null
  existing_gklm_pm_ntw_id     = var.scale_encryption_enabled == true && var.vpc_name != null  && local.existing_gklm_dns_zone_id != null ? (length(data.ibm_dns_permitted_networks.existing_gklm_pm_ntw[0].dns_permitted_networks) > 0 ? tolist(data.ibm_dns_permitted_networks.existing_gklm_pm_ntw[0].dns_permitted_networks[*].permitted_network_id)[0] : null) : null
  existing_protocol_pm_ntw_id = local.scale_ces_enabled == true && var.vpc_name != null && local.existing_protocol_dns_zone_id != null ? (length(data.ibm_dns_permitted_networks.existing_protocol_pm_ntw[0].dns_permitted_networks) > 0 ? tolist(data.ibm_dns_permitted_networks.existing_protocol_pm_ntw[0].dns_permitted_networks[*].permitted_network_id)[0] : null) : null
  existing_client_pm_ntw_id   = local.create_client_cluster == true && var.vpc_name != null && local.existing_protocol_dns_zone_id != null ? (length(data.ibm_dns_permitted_networks.existing_client_pm_ntw[0].dns_permitted_networks) > 0 ? tolist(data.ibm_dns_permitted_networks.existing_client_pm_ntw[0].dns_permitted_networks[*].permitted_network_id)[0] : null) : null
}
*/

locals {
  validate_vpc_availability_zones_cnd = length(setsubtract(var.vpc_availability_zones, data.ibm_is_zones.itself.zones))
  vpc_availability_zones_msg          = "Specified input list for vpc_availability_zones is not valid."
  validate_vpc_availability_zones_chk = regex("^${local.vpc_availability_zones_msg}$", (local.validate_vpc_availability_zones_cnd == 0 ? local.vpc_availability_zones_msg : ""))
}

locals {
  validate_zone                  = var.storage_type == "persistent" ? contains(["us-south-1", "us-south-3", "eu-de-1", "eu-de-2", "jp-tok-2", "jp-tok-3"], join(",", var.vpc_availability_zones)) : true
  zone_msg                       = "The solution supports bare metal server creation in only given availability zones i.e. us-south-1, us-south-3, eu-de-1, eu-de-2, jp-tok-2 and jp-tok-3. To deploy persistent storage provide any one of the supported availability zones."
  validate_persistent_region_chk = regex("^${local.zone_msg}$", (local.validate_zone ? local.zone_msg : ""))
}

locals {
  icn_cnd = (var.storage_type != "evaluation" && var.ibm_customer_number == "") ? false : true
  icn_msg = "The IBM customer number input value can't be empty."
  icn_chk = regex("^${local.icn_msg}$", (local.icn_cnd ? local.icn_msg : ""))
}

data "ibm_is_instance_profile" "bastion" {
  name = var.bastion_vsi_profile
}

data "ibm_is_instance_profile" "bootstrap" {
  name = var.bootstrap_vsi_profile
}

data "ibm_is_instance_profile" "compute_vsi" {
  name = var.compute_vsi_profile
}

data "ibm_is_instance_profile" "storage_vsi" {
  name  = var.storage_vsi_profile
  count = var.storage_type != "persistent" ? 1 : 0
}

data "ibm_is_bare_metal_server_profile" "storage_bare_metal_server" {
  name  = var.storage_bare_metal_server_profile
  count = var.storage_type == "persistent" ? 1 : 0
}

data "ibm_is_ssh_key" "bastion_ssh_key" {
  count = length(var.bastion_key_pair)
  name  = var.bastion_key_pair[count.index]
}

data "ibm_is_ssh_key" "compute_ssh_key" {
  count = var.compute_cluster_key_pair != null ? length(var.compute_cluster_key_pair) : 0
  name  = var.compute_cluster_key_pair[count.index]
}

data "ibm_is_ssh_key" "storage_ssh_key" {
  count = length(var.storage_cluster_key_pair)
  name  = var.storage_cluster_key_pair[count.index]
}

data "ibm_is_ssh_key" "client_ssh_key" {
  count = var.client_cluster_key_pair != null ? length(var.client_cluster_key_pair) : 0
  name  = var.client_cluster_key_pair[count.index]
}

data "ibm_is_ssh_key" "encryption_ssh_key" {
  count = var.scale_encryption_instance_key_pair != null ? length(var.scale_encryption_instance_key_pair) : 0
  name  = var.scale_encryption_instance_key_pair[count.index]
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
    (local.validate_bastion_os
      ? local.validate_bastion_os_msg
  : ""))
}

locals {
  // Check whether an entry is found in the mapping file for the given bootstrap node image
  bootstrap_image_mapping_entry_found = contains(keys(local.bootstrap_image_region_map), var.bootstrap_osimage_name)
  bootstrap_image_id                  = local.bootstrap_image_mapping_entry_found ? lookup(lookup(local.bootstrap_image_region_map, var.bootstrap_osimage_name), local.vpc_region) : "Image not found with the given name"

  // Check whether an entry is found in the mapping file for the given compute node image
  compute_image_mapping_entry_found = contains(keys(local.compute_image_region_map), var.compute_vsi_osimage_name)
  compute_image_id                  = var.storage_type == "evaluation" && !(local.compute_image_mapping_entry_found) ? lookup(lookup(local.evaluation_image_region_map, one(keys(local.evaluation_image_region_map))), local.vpc_region) : local.compute_image_mapping_entry_found ? lookup(lookup(local.compute_image_region_map, var.compute_vsi_osimage_name), local.vpc_region) : data.ibm_is_image.compute_image[0].id
  compute_osimage_name              = var.storage_type == "evaluation" && !(local.compute_image_mapping_entry_found) ? one(keys(local.evaluation_image_region_map)) : local.compute_image_mapping_entry_found ? var.compute_vsi_osimage_name : data.ibm_is_image.compute_image[0].name

  // Check whether an entry is found in the mapping file for the given storage node image
  storage_image_mapping_entry_found = contains(keys(local.storage_image_region_map), var.storage_vsi_osimage_name)
  storage_image_id                  = var.storage_type == "evaluation" ? lookup(lookup(local.evaluation_image_region_map, one(keys(local.evaluation_image_region_map))), local.vpc_region) : local.storage_image_mapping_entry_found ? lookup(lookup(local.storage_image_region_map, var.storage_vsi_osimage_name), local.vpc_region) : data.ibm_is_image.storage_image[0].id
  storage_osimage_name              = var.storage_type == "evaluation" ? one(keys(local.evaluation_image_region_map)) : local.storage_image_mapping_entry_found ? var.storage_vsi_osimage_name : data.ibm_is_image.storage_image[0].name

  // Check whether an entry is found in the mapping file for the given bare metal storage node image
  storage_bare_metal_image_mapping_entry_found = contains(keys(local.storage_image_region_map), var.storage_bare_metal_osimage_name)
  storage_bare_metal_image_id                  = local.storage_bare_metal_image_mapping_entry_found ? lookup(lookup(local.storage_image_region_map, var.storage_bare_metal_osimage_name), local.vpc_region) : data.ibm_is_image.bare_metal_image[0].id
  storage_bare_metal_osimage_name              = local.storage_bare_metal_image_mapping_entry_found ? var.storage_bare_metal_osimage_name : data.ibm_is_image.bare_metal_image[0].name

  // Check whether an entry is found in the mapping file for the given GKLM image
  scale_encryption_image_mapping_entry_found = contains(keys(local.scale_encryption_image_region_map), var.scale_encryption_vsi_osimage_name)
  scale_encryption_image_id                  = var.scale_encryption_enabled == true && !(local.scale_encryption_image_mapping_entry_found) ? lookup(lookup(local.scale_encryption_image_region_map, one(keys(local.scale_encryption_image_region_map))), local.vpc_region) : local.scale_encryption_image_mapping_entry_found ? lookup(lookup(local.scale_encryption_image_region_map, var.scale_encryption_vsi_osimage_name), local.vpc_region) : data.ibm_is_image.scale_encryption_image[0].id
  scale_encryption_osimage_name              = var.scale_encryption_enabled == true && !(local.scale_encryption_image_mapping_entry_found) ? one(keys(local.scale_encryption_image_region_map)) : local.scale_encryption_image_mapping_entry_found ? var.scale_encryption_vsi_osimage_name : data.ibm_is_image.scale_encryption_image[0].name
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
  count = local.storage_image_mapping_entry_found ? 0 : 1
}

data "ibm_is_image" "bare_metal_image" {
  name  = var.storage_bare_metal_osimage_name
  count = local.storage_bare_metal_image_mapping_entry_found ? 0 : 1
}

data "ibm_is_image" "scale_encryption_image" {
  name  = var.scale_encryption_vsi_osimage_name
  count = local.scale_encryption_image_mapping_entry_found ? 0 : 1
}

locals {
  validate_storage_gui_username_cnd = (length(var.storage_cluster_gui_username) >= 4 && length(var.storage_cluster_gui_username) <= 32 && trimspace(var.storage_cluster_gui_username) != "")
  storage_gui_username_msg          = "Specified input for \"storage_cluster_gui_username\" is not valid.username should be greater or equal to 4 letters."
  validate_storage_gui_username_chk = regex("^${local.storage_gui_username_msg}$", (local.validate_storage_gui_username_cnd ? local.storage_gui_username_msg : ""))

  validate_compute_gui_username_cnd = var.total_compute_cluster_instances > 0 ? (length(var.compute_cluster_gui_username) >= 4 && length(var.compute_cluster_gui_username) <= 32 && trimspace(var.compute_cluster_gui_username) != "") : true
  compute_gui_username_msg          = "Specified input for \"compute_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  validate_compute_gui_username_chk = regex("^${local.compute_gui_username_msg}$", (local.validate_compute_gui_username_cnd ? local.compute_gui_username_msg : ""))

  validate_storage_gui_password_cnd = (replace(lower(var.storage_cluster_gui_password), lower(var.storage_cluster_gui_username), "") == lower(var.storage_cluster_gui_password))
  storage_gui_password_msg          = "Storage cluster GUI password should not contain username."
  validate_storage_gui_password_chk = regex("^${local.storage_gui_password_msg}$", (local.validate_storage_gui_password_cnd ? local.storage_gui_password_msg : ""))

  validate_compute_gui_password_cnd = var.total_compute_cluster_instances > 0 ? ((replace(lower(var.compute_cluster_gui_password), lower(var.compute_cluster_gui_username), "") == lower(var.compute_cluster_gui_password)) && can(regex("^.{8,}$", var.compute_cluster_gui_password) != "") && can(regex("[0-9]{1,}", var.compute_cluster_gui_password) != "") && can(regex("[a-z]{1,}", var.compute_cluster_gui_password) != "") && can(regex("[A-Z]{1,}", var.compute_cluster_gui_password) != "") && can(regex("[!@#$%^&*()_+=-]{1,}", var.compute_cluster_gui_password) != "") && trimspace(var.compute_cluster_gui_password) != "" && can(regex("^[!@#$%^&*()_+=-]", var.compute_cluster_gui_password)) == false) : true
  compute_gui_password_msg          = "Compute cluster GUI password should contain minimum of 8 characters and for strong password it must be a combination of uppercase letter, lowercase letter, one number and a special character. Ensure password doesn't comprise with username and it should not start with a special character."
  validate_compute_gui_password_chk = regex("^${local.compute_gui_password_msg}$", (local.validate_compute_gui_password_cnd ? local.compute_gui_password_msg : ""))
}


locals {
  total_storage_capacity      = var.storage_type == "evaluation" ? data.ibm_is_instance_profile.storage_vsi[0].disks[0].quantity[0].value * data.ibm_is_instance_profile.storage_vsi[0].disks[0].size[0].value * var.total_storage_cluster_instances : 0
  evaluation_storage_type_cnd = var.storage_type == "evaluation" && local.total_storage_capacity > 12000 ? false : true
  evaluation_storage_type_msg = "The evaluation storage type supports 12TB storage capacity."
  evaluation_storage_type_chk = regex("^${local.evaluation_storage_type_msg}$", (local.evaluation_storage_type_cnd ? local.evaluation_storage_type_msg : ""))
}

locals {
  GKLM_server_count_msg = "Setting up a high-availability encryption server. You need to choose at least 2 and the maximum number of 5."

  // GKLM Server count
  validate_GKLM_server_count = (var.scale_encryption_enabled && var.scale_encryption_server_count >= 2 && var.scale_encryption_server_count <= 5) || !var.scale_encryption_enabled
  validate_GKLM_server_count_chk = regex(
    "^${local.GKLM_server_count_msg}$",
  (local.validate_GKLM_server_count ? local.GKLM_server_count_msg : ""))

  // GKLM password validation
  validate_GKLM_pwd = (var.scale_encryption_enabled && length(var.scale_encryption_admin_password) >= 8 && length(var.scale_encryption_admin_password) <= 20 && can(regex("^(.*[0-9]){2}.*$", var.scale_encryption_admin_password))) && can(regex("^(.*[A-Z]){1}.*$", var.scale_encryption_admin_password)) && can(regex("^(.*[a-z]){1}.*$", var.scale_encryption_admin_password)) && can(regex("^.*[~@_+:].*$", var.scale_encryption_admin_password)) && can(regex("^[^!#$%^&*()=}{\\[\\]|\\\"';?.<,>-]+$", var.scale_encryption_admin_password)) || !var.scale_encryption_enabled
  password_msg      = "Password that is used for performing administrative operations for the GKLM.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character. Make sure that the password doesn't include the username."
  validate_GKLM_pwd_chk = regex(
    "^${local.password_msg}$",
  (local.validate_GKLM_pwd ? local.password_msg : ""))

  // GKLM keypair validation
  validate_GKLM_keypair = (var.scale_encryption_enabled && var.scale_encryption_instance_key_pair == "")
  keypair_msg           = "SSH-Keypair should not be empty when encryption is enabled."
  gklm_keypair_check    = regex("^${local.keypair_msg}$", (local.validate_GKLM_keypair ? "" : local.keypair_msg))
}

# LDAP Variable Validation
locals {
  ldap_server_status = var.enable_ldap == true && var.ldap_server == "null" ? false : true

  // LDAP base DNS Validation
  validate_ldap_basedns = (var.enable_ldap && trimspace(var.ldap_basedns) != "") || !var.enable_ldap
  ldap_basedns_msg      = "If LDAP is enabled, then the base DNS should not be empty or null. Need a valid domain name."
  validate_ldap_basedns_chk = regex(
    "^${local.ldap_basedns_msg}$",
  (local.validate_ldap_basedns ? local.ldap_basedns_msg : ""))

  // LDAP base existing LDAP server
  validate_ldap_server = (var.enable_ldap && trimspace(var.ldap_server) != "") || !var.enable_ldap
  ldap_server_msg      = "IP of existing LDAP server. If none given a new ldap server will be created. It should not be empty."
  validate_ldap_server_chk = regex(
    "^${local.ldap_server_msg}$",
  (local.validate_ldap_server ? local.ldap_server_msg : ""))

  // LDAP Admin Password Validation
  validate_ldap_adm_pwd = var.enable_ldap && var.ldap_server == "null" ? (length(var.ldap_admin_password) >= 8 && length(var.ldap_admin_password) <= 20 && can(regex("^(.*[0-9]){2}.*$", var.ldap_admin_password))) && can(regex("^(.*[A-Z]){1}.*$", var.ldap_admin_password)) && can(regex("^(.*[a-z]){1}.*$", var.ldap_admin_password)) && can(regex("^.*[~@_+:].*$", var.ldap_admin_password)) && can(regex("^[^!#$%^&*()=}{\\[\\]|\\\"';?.<,>-]+$", var.ldap_admin_password)) : local.ldap_server_status
  ldap_adm_password_msg = "Password that is used for LDAP admin.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character. Make sure that the password doesn't include the username."
  validate_ldap_adm_pwd_chk = regex(
    "^${local.ldap_adm_password_msg}$",
  (local.validate_ldap_adm_pwd ? local.ldap_adm_password_msg : ""))

  // LDAP User Validation
  validate_ldap_usr = var.enable_ldap && var.ldap_server == "null" ? (length(var.ldap_user_name) >= 4 && length(var.ldap_user_name) <= 32 && var.ldap_user_name != "" && can(regex("^[a-zA-Z0-9_-]*$", var.ldap_user_name)) && trimspace(var.ldap_user_name) != "") : local.ldap_server_status
  ldap_usr_msg      = "The input for 'ldap_user_name' is considered invalid. The username must be within the range of 4 to 32 characters and may only include letters, numbers, hyphens, and underscores. Spaces are not permitted."
  validate_ldap_usr_chk = regex(
    "^${local.ldap_usr_msg}$",
  (local.validate_ldap_usr ? local.ldap_usr_msg : ""))

  // LDAP User Password Validation
  validate_ldap_usr_pwd = var.enable_ldap && var.ldap_server == "null" ? (length(var.ldap_user_password) >= 8 && length(var.ldap_user_password) <= 20 && can(regex("^(.*[0-9]){2}.*$", var.ldap_user_password))) && can(regex("^(.*[A-Z]){1}.*$", var.ldap_user_password)) && can(regex("^(.*[a-z]){1}.*$", var.ldap_user_password)) && can(regex("^.*[~@_+:].*$", var.ldap_user_password)) && can(regex("^[^!#$%^&*()=}{\\[\\]|\\\"';?.<,>-]+$", var.ldap_user_password)) : local.ldap_server_status
  ldap_usr_password_msg = "Password that is used for LDAP user.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character. Make sure that the password doesn't include the username."
  validate_ldap_usr_pwd_chk = regex(
    "^${local.ldap_usr_password_msg}$",
  (local.validate_ldap_usr_pwd ? local.ldap_usr_password_msg : ""))

  // LDAP Keypair Validation
  validate_LDAP_keypair = (var.enable_ldap && var.ldap_instance_key_pair == null)
  ldap_keypair_msg      = "SSH-Keypair should not be empty when LDAP is enabled."
  ldap_keypair_check    = regex("^${local.ldap_keypair_msg}$", (local.validate_LDAP_keypair ? "" : local.ldap_keypair_msg))
}

locals {
  schematics_ip = [
    "169.45.235.176/28",
    "169.55.82.128/27",
    "169.60.115.32/27",
    "169.63.150.144/28",
    "169.62.1.224/28",
    "169.62.53.64/27",
    "150.238.230.128/27",
    "169.63.254.64/28",
    "169.47.104.160/28",
    "169.61.191.64/27",
    "169.60.172.144/28",
    "169.62.204.32/27",
    "158.175.106.64/27",
    "158.175.138.176/28",
    "141.125.79.160/28",
    "141.125.142.96/27",
    "158.176.111.64/27",
    "158.176.134.80/28",
    "149.81.123.64/27",
    "149.81.135.64/28",
    "158.177.210.176/28",
    "158.177.216.144/28",
    "161.156.138.80/28",
    "159.122.111.224/27",
    "161.156.37.160/27"
  ]
}