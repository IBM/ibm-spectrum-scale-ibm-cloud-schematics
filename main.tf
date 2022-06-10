/*
    IBM Spectrum scale cloud deployment requires 1 VPC with below resources.

    1.  VPC options
    2.  VPC address prefix
    3.  Public subnet / Gateway
    4.  PrivateSubnet {1, 2 ..3}
    5.  DNS service
    6.  Login and Bootstrap Node
    7.  Trusted Profile for authentication purpose
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group
}

locals {
  tags = ["HPCC", var.resource_prefix]
  vpc_create_activity_tracker = "false"
  vpc_activity_tracker_plan_type = "lite"
  vpc_create_separate_subnets = true
  using_rest_api_remote_mount = true
}

locals {
  validate_storage_gui_password_cnd = (replace(lower(var.storage_cluster_gui_password), lower(var.storage_cluster_gui_username), "" ) == lower(var.storage_cluster_gui_password))
  gui_password_msg = "Password Should not contain username"
  validate_storage_gui_password_chk = regex("^${local.gui_password_msg}$", ( local.validate_storage_gui_password_cnd ? local.gui_password_msg : "") )

  // validate compute gui password
  validate_compute_gui_password_cnd = (replace(lower(var.compute_cluster_gui_password), lower(var.compute_cluster_gui_username),"") == lower(var.compute_cluster_gui_password))
  validate_compute_gui_password_chk = regex("^${local.gui_password_msg}$", ( local.validate_compute_gui_password_cnd ? local.gui_password_msg : "") )


   //validate scale storage gui user name
  validate_scale_storage_gui_username_cnd = (length(var.storage_cluster_gui_username) >= 4 && length(var.storage_cluster_gui_username) <= 32 && trimspace(var.storage_cluster_gui_username) != "")
  storage_gui_username_msg = "Specified input for \"storage_cluster_gui_username\" is not valid.username should be greater or equal to 4 letters."
  validate_storage_gui_username_chk = regex("^${local.storage_gui_username_msg}", (local.validate_scale_storage_gui_username_cnd? local.storage_gui_username_msg: ""))

  validate_compute_gui_username_cnd = (length(var.compute_cluster_gui_username) >= 4 && length(var.compute_cluster_gui_username) <= 32 && trimspace(var.compute_cluster_gui_username) != "")
  compute_gui_username_msg = "Specified input for \"compute_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  validate_compute_gui_username_chk = regex("^${local.compute_gui_username_msg}", (local.validate_compute_gui_username_cnd? local.compute_gui_username_msg: ""))


  //validate Bastion os image.
  bastion_os = split("-", data.ibm_is_image.bastion_image.os)[0]
  validate_bastion_os = local.bastion_os == "ubuntu"
  validate_bastion_os_msg = "Error: Invalid custom image name. Our automation currently supports only ubuntu stock images of any version available on that region."
  validate_bastion_os_chk = regex(
      "^${local.validate_bastion_os_msg}$",
      ( local.validate_bastion_os
        ? local.validate_bastion_os_msg
        : "" ) )

  // Check whether an entry is found in the mapping file for the given bootstrap node image
  bootstrap_image_mapping_entry_found = contains(keys(local.bootstrap_image_region_map), var.bootstrap_osimage_name)
  bootstrap_image_id = local.bootstrap_image_mapping_entry_found ? lookup(lookup(local.bootstrap_image_region_map, var.bootstrap_osimage_name), var.vpc_region) : "Image not found with the given name"

  // Check whether an entry is found in the mapping file for the given compute node image
  compute_image_mapping_entry_found = contains(keys(local.compute_image_region_map), var.compute_vsi_osimage_name)
  compute_image_id = local.compute_image_mapping_entry_found ? lookup(lookup(local.compute_image_region_map, var.compute_vsi_osimage_name), var.vpc_region) : data.ibm_is_image.compute_image[0].id
  compute_osimage_name = local.compute_image_mapping_entry_found ? var.compute_vsi_osimage_name : data.ibm_is_image.compute_image[0].name

  // Check whether an entry is found in the mapping file for the given storage node image
  storage_image_mapping_entry_found = contains(keys(local.storage_image_region_map), var.storage_vsi_osimage_name)
  storage_image_id = local.storage_image_mapping_entry_found ? lookup(lookup(local.storage_image_region_map, var.storage_vsi_osimage_name), var.vpc_region) : data.ibm_is_image.storage_image[0].id
  storage_osimage_name = local.storage_image_mapping_entry_found ? var.storage_vsi_osimage_name : data.ibm_is_image.storage_image[0].name

}

data "ibm_is_image" "compute_image" {
  name = var.compute_vsi_osimage_name
  count = local.compute_image_mapping_entry_found ? 0:1
}

data "ibm_is_image" "storage_image" {
  name = var.storage_vsi_osimage_name
  count = local.storage_image_mapping_entry_found ? 0:1
}

data "ibm_is_ssh_key" "bastion_ssh_key" {
  name = var.bastion_key_pair
}

data "ibm_is_ssh_key" "compute_ssh_key" { # This block is trying to fetch the key_pair details for compute node, which is dependent on the code present on public repo
  name = var.compute_cluster_key_pair
}

data "ibm_is_ssh_key" "storage_ssh_key" { # This block is trying to fetch the key_pair details for compute node, which is dependent on the code present on public repo
  name = var.storage_cluster_key_pair
}

module "vpc" {
  source                        = "./resources/ibmcloud/network/vpc"
  vpc_name                      = format("%s-vpc", var.resource_prefix)
  vpc_address_prefix_management = "manual"
  vpc_sg_name                   = format("%s-vpc-sg", var.resource_prefix)
  vpc_rt_name                   = format("%s-vpc-rt", var.resource_prefix)
  vpc_nw_acl_name               = format("%s-vpc-nwacl", var.resource_prefix)
  resource_group_id             = data.ibm_resource_group.itself.id
  tags                          = local.tags
}

module "vpc_address_prefix" {
  source       = "./resources/ibmcloud/network/vpc_address_prefix"
  vpc_id       = module.vpc.vpc_id
  address_name = format("%s-addr", var.resource_prefix)
  zones        = var.vpc_availability_zones
  cidr_block   = var.vpc_cidr_block
}

module "common_public_gw" {
  source            = "./resources/ibmcloud/network/public_gw"
  public_gw_name    = format("%s-gw", var.resource_prefix)
  resource_group_id = data.ibm_resource_group.itself.id
  vpc_id            = module.vpc.vpc_id
  zones             = var.vpc_availability_zones
  tags              = local.tags
}

module "storage_private_subnet" {
  source            = "./resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-strg-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_storage_cluster_private_subnets_cidr_blocks
  public_gateway    = module.common_public_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
  tags              = local.tags
}

module "compute_private_subnet" {
  source            = "./resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = local.vpc_create_separate_subnets == true ? [var.vpc_availability_zones[0]] : []
  subnet_name       = format("%s-comp-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_compute_cluster_private_subnets_cidr_blocks
  public_gateway    = module.common_public_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
  tags              = local.tags
}

module "dns_service" {
  source                 = "./resources/ibmcloud/resource_instance"
  service_count          = 1
  resource_instance_name = [format("%s-scaledns", var.resource_prefix)]
  resource_group_id      = data.ibm_resource_group.itself.id
  target_location        = "global"
  service_name           = "dns-svcs"
  plan_type              = "standard-dns"
  tags                   = local.tags
}

module "storage_dns_zone" {
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_storage_cluster_dns_domain
  dns_service_id = module.dns_service.resource_guid[0]
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
}

module "storage_dns_permitted_network" {
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = module.dns_service.resource_guid[0]
  zone_id         = module.storage_dns_zone.dns_zone_id
  vpc_crn         = module.vpc.vpc_crn
}

module "compute_dns_zone" {
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_compute_cluster_dns_domain
  dns_service_id = module.dns_service.resource_guid[0]
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "compute_dns_permitted_network" {
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = local.vpc_create_separate_subnets == true ? 1 : 0
  instance_id     = module.dns_service.resource_guid[0]
  zone_id         = module.compute_dns_zone.dns_zone_id
  vpc_crn         = module.vpc.vpc_crn
  depends_on      = [module.storage_dns_permitted_network]
}

# FIXME: Multi-az, Add update resolver
module "custom_resolver_storage_subnet" { # While creating the custom resolver, we are associating two subnet directly and we are not using the locations explict as there is some issue with that
  source                 = "./resources/ibmcloud/network/dns_custom_resolver"
  customer_resolver_name = format("%s-vpc-resolver", var.resource_prefix)
  instance_guid          = module.dns_service.resource_guid[0]
  description            = "Private DNS custom resolver for Spectrum Scale VPC DNS communication."
  storage_subnet_crn = module.storage_private_subnet.subnet_crn[0]
  compute_subnet_crn = module.compute_private_subnet.subnet_crn[0]
}

data "http" "fetch_myip"{
  url = "http://ipv4.icanhazip.com"
}

module "bastion_security_group" {
  source            = "./resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = [format("%s-bastion-sg", var.resource_prefix)]
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  tags              = local.tags
}

module "bastion_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
}

module "schematics_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = tolist(["${chomp(data.http.fetch_myip.body)}"])
}

module "bastion_https_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_https_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
}

module "bastion_sg_icmp_rule" {
  source            = "./resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks[0]
}

module "bastion_sg_outbound_rule" {
  source             = "./resources/ibmcloud/security/security_allow_all"
  turn_on            = true
  security_group_ids = module.bastion_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}


data "ibm_is_image" "bastion_image" {
  name = var.bastion_osimage_name
}

module "bastion_proxy_ssh_keys" {
  source  = "./resources/common/generate_keys"
  turn_on = true
}

module "bastion_vsi" {
  source              = "./resources/ibmcloud/compute/bastion_vsi"
  vsi_name_prefix     = format("%s-bastion", var.resource_prefix)
  vpc_id              = module.vpc.vpc_id
  vpc_zone            = var.vpc_availability_zones[0]
  resource_grp_id     = data.ibm_resource_group.itself.id
  vsi_subnet_id       = module.storage_private_subnet.subnet_id[0]
  vsi_security_group  = [module.bastion_security_group.sec_group_id]
  vsi_profile         = var.bastion_vsi_profile
  vsi_image_id        = data.ibm_is_image.bastion_image.id
  vsi_user_public_key = [data.ibm_is_ssh_key.bastion_ssh_key.id]
  vsi_meta_public_key = module.bastion_proxy_ssh_keys.public_key_content
  tags              = local.tags
}

module "bastion_attach_fip" {
  source            = "./resources/ibmcloud/network/floating_ip"
  floating_ip_name  = format("%s-bastion-fip", var.resource_prefix)
  vsi_nw_id         = module.bastion_vsi.vsi_nw_id
  resource_group_id = data.ibm_resource_group.itself.id
  tags              = local.tags
}

module "bootstrap_security_group" {
  source            = "./resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = [format("%s-bootstrap-sg", var.resource_prefix)]
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  tags              = local.tags
}

module "bootstrap_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bootstrap_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = tolist([module.bastion_security_group.sec_group_id])
}

module "bootstrap_sg_icmp_rule" {
  source            = "./resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.bootstrap_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks[0]
}

module "bootstrap_sg_outbound_rule" {
  source             = "./resources/ibmcloud/security/security_allow_all"
  turn_on            = true
  security_group_ids = module.bootstrap_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

data "ibm_is_image" "bootstrap_image" {
  count = local.bootstrap_image_mapping_entry_found ? 0:1
  name = var.bootstrap_osimage_name
}

module "bootstrap_ssh_keys" {
  source  = "./resources/common/generate_keys"
  turn_on = true
}

locals {
  turn_on_init            = fileexists("/tmp/.schematics/success") ? false : true
  bootstrap_path          = "/opt/IBM"
  remote_gpfs_rpms_path   = format("%s/gpfs_cloud_rpms", local.bootstrap_path)
  remote_ansible_path     = format("%s/ibm-spectrumscale-cloud-deploy", local.bootstrap_path)
  remote_terraform_path   = format("%s/ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template", local.remote_ansible_path)
  schematics_inputs_path  = "/tmp/.schematics/scale_terraform.auto.tfvars.json"
  scale_cred_path         = "/tmp/.schematics/scale_credentials.json"
  remote_inputs_path      = format("%s/terraform.tfvars.json", "/tmp")
  remote_scale_cred_path  = format("%s/scale_credentials.json", "/tmp")
  zones                   = jsonencode(var.vpc_availability_zones)
  compute_private_subnets = jsonencode(module.compute_private_subnet.subnet_id)
  storage_private_subnets = jsonencode(module.storage_private_subnet.subnet_id)
  scale_cluster_resource_tags = jsonencode(local.tags)
}

resource "local_file" "prepare_scale_vsi_input" {
  sensitive_content = <<EOT
{
    "resource_group_id": "${data.ibm_resource_group.itself.id}",
    "resource_prefix": "${var.resource_prefix}",
    "vpc_region": "${var.vpc_region}",
    "vpc_availability_zones": ${local.zones},
    "vpc_id": "${module.vpc.vpc_id}",
    "vpc_compute_cluster_private_subnets": ${local.compute_private_subnets},
    "vpc_storage_cluster_private_subnets": ${local.storage_private_subnets},
    "vpc_custom_resolver_id": "${module.custom_resolver_storage_subnet.custom_resolver_id}",
    "vpc_compute_cluster_dns_service_id": "${module.dns_service.resource_guid[0]}",
    "vpc_storage_cluster_dns_service_id": "${module.dns_service.resource_guid[0]}",
    "vpc_compute_cluster_dns_zone_id": "${module.compute_dns_zone.dns_zone_id}",
    "vpc_storage_cluster_dns_zone_id": "${module.storage_dns_zone.dns_zone_id}",
    "vpc_compute_cluster_dns_domain": "${var.vpc_compute_cluster_dns_domain}",
    "vpc_storage_cluster_dns_domain": "${var.vpc_storage_cluster_dns_domain}",
    "vpc_create_activity_tracker": ${local.vpc_create_activity_tracker},
    "activity_tracker_plan_type": "${local.vpc_activity_tracker_plan_type}",
    "compute_cluster_gui_username": "${var.compute_cluster_gui_username}",
    "compute_cluster_gui_password": "${var.compute_cluster_gui_password}",
    "compute_cluster_key_pair": "${var.compute_cluster_key_pair}",
    "total_compute_cluster_instances": ${var.total_compute_cluster_instances},
    "compute_vsi_osimage_name": "${local.compute_osimage_name}",
    "compute_vsi_profile": "${var.compute_vsi_profile}",
    "using_rest_api_remote_mount": ${local.using_rest_api_remote_mount},
    "storage_cluster_gui_password": "${var.storage_cluster_gui_password}",
    "storage_cluster_gui_username": "${var.storage_cluster_gui_username}",
    "storage_cluster_key_pair": "${var.storage_cluster_key_pair}",
    "total_storage_cluster_instances": "${var.total_storage_cluster_instances}",
    "storage_vsi_osimage_name": "${local.storage_osimage_name}",
    "storage_vsi_profile": "${var.storage_vsi_profile}",
    "storage_cluster_filesystem_mountpoint": "${var.storage_cluster_filesystem_mountpoint}",
    "compute_cluster_filesystem_mountpoint": "${var.compute_cluster_filesystem_mountpoint}",
    "filesystem_block_size": "${var.filesystem_block_size}",
    "spectrumscale_rpms_path": "${local.remote_gpfs_rpms_path}",
    "scale_ansible_repo_clone_path": "${local.remote_ansible_path}",
    "deploy_controller_sec_group_id": "${module.bootstrap_security_group.sec_group_id}",
    "bastion_security_group_id": "${module.bastion_security_group.sec_group_id}",
    "bastion_instance_public_ip": null,
    "bastion_instance_id": null,
    "bastion_ssh_private_key": null,
    "using_direct_connection": true,
    "scale_cluster_resource_tags": ${local.scale_cluster_resource_tags},
    "compute_vsi_osimage_id": "${local.compute_image_id}",
    "storage_vsi_osimage_id": "${local.storage_image_id}"
}
EOT
  filename          = local.schematics_inputs_path
}

resource "local_file" "prepare_scale_cred_input" {
  sensitive_content = <<EOT
{
    "ibm_customer_number": "${var.ibm_customer_number}"
}
EOT
  filename          = local.scale_cred_path
}


module "bootstrap_trusted_profile" {
  source                      = "./resources/ibmcloud/security/iam/trusted_profile"
  trusted_profile_name        = format("%s-bootstrap", var.resource_prefix)
  trusted_profile_description = "Bootstrap trusted profile"
}


module "bootstrap_trusted_profile_is_policy" {
  source                = "./resources/ibmcloud/security/iam/trusted_profile_is_policy"
  trusted_profile_id    = module.bootstrap_trusted_profile.trusted_profile_id
  trusted_profile_roles = ["Administrator"]
  resource_group_id     = data.ibm_resource_group.itself.id
}


module "bootstrap_trusted_profile_dns_policy" {
  source                = "./resources/ibmcloud/security/iam/trusted_profile_dns_policy"
  trusted_profile_id    = module.bootstrap_trusted_profile.trusted_profile_id
  trusted_profile_roles = ["Administrator","Manager"]
  resource_group_id     = data.ibm_resource_group.itself.id
}

module "bootstrap_trusted_profile_vpc_policy" {
  source                = "./resources/ibmcloud/security/iam/trusted_profile_vpc_policy"
  trusted_profile_id    = module.bootstrap_trusted_profile.trusted_profile_id
  trusted_profile_roles = ["Administrator"]
  resource_group_id     = data.ibm_resource_group.itself.id
}

module "bootstrap_trusted_profile_resource_group_policy" {
  source                = "./resources/ibmcloud/security/iam/trusted_profile_resource_group_policy"
  trusted_profile_id    = module.bootstrap_trusted_profile.trusted_profile_id
  trusted_profile_roles = ["Administrator"]
  resource_group_id     = data.ibm_resource_group.itself.id
}

/*
    Notes:
    1. The bootstrap vsi is created with passwordless setup with schematics.
    2. The public key is stored in state file, which will be used for polling the deployer
       init process state.
*/

module "bootstrap_vsi" {
  source               = "./resources/ibmcloud/compute/bootstrap_vsi"
  vsi_name_prefix      = format("%s-bootstrap", var.resource_prefix)
  vpc_id               = module.vpc.vpc_id
  vpc_zone             = var.vpc_availability_zones[0]
  resource_grp_id      = data.ibm_resource_group.itself.id
  vsi_subnet_id        = module.storage_private_subnet.subnet_id[0]
  vsi_security_group   = [module.bootstrap_security_group.sec_group_id]
  vsi_profile          = var.bootstrap_vsi_profile
  vsi_image_id         = local.bootstrap_image_mapping_entry_found ? local.bootstrap_image_id : data.ibm_is_image.bootstrap_image[0].id
  vsi_user_public_key  = [data.ibm_is_ssh_key.bastion_ssh_key.id]
  vsi_meta_private_key = module.bootstrap_ssh_keys.private_key_content
  vsi_meta_public_key  = module.bootstrap_ssh_keys.public_key_content
  tags                 = local.tags
}

module "bootstrap_link_profile" {
  source                    = "./resources/ibmcloud/security/iam/trusted_profile_link"
  trusted_profile_id        = module.bootstrap_trusted_profile.trusted_profile_id
  target_vsi_crn            = module.bootstrap_vsi.vsi_crn
  trusted_profile_link_name = format("%s-link-profile", var.resource_prefix)
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
  depends_on      = [module.bootstrap_vsi]
}

resource "null_resource" "bootstrap_status" {
  connection {
    type        = "ssh"
    host        = module.bootstrap_vsi.vsi_private_ip
    user        = "vpcuser"
    private_key = module.bootstrap_ssh_keys.private_key_content
    bastion_host = module.bastion_attach_fip.floating_ip_addr
    bastion_user = "ubuntu"
    bastion_private_key = module.bastion_proxy_ssh_keys.private_key_content
  }

  provisioner "file" {
    source      = local.schematics_inputs_path
    destination = local.remote_inputs_path
  }

  provisioner "file" {
    source      = local.scale_cred_path
    destination = local.remote_scale_cred_path
  }

  provisioner "remote-exec" {
    inline = [
      "sudo python3 /opt/IBM/ibm-spectrumscale-cloud-deploy/cloud_deploy/cloud_deployer.py ibmcloud --profile-id ${module.bootstrap_trusted_profile.trusted_profile_id} --schematics-input-file /tmp/terraform.tfvars.json"
    ]
  }
  depends_on = [module.bootstrap_vsi, module.bastion_attach_fip, time_sleep.wait_60_seconds, local_file.prepare_scale_vsi_input]
}

data "ibm_iam_auth_token" "token" {}

resource "null_resource" "delete_schematics_ingress_security_rule" {
  provisioner "local-exec" {
    environment = {
      REFRESH_TOKEN       = data.ibm_iam_auth_token.token.iam_refresh_token
      REGION              = var.vpc_region
      SECURITY_GROUP      = module.bastion_security_group.sec_group_id
      SECURITY_GROUP_RULE = module.schematics_sg_tcp_rule.security_rule_id[0]
    }
    command     = <<EOT
          echo $SECURITY_GROUP
          echo $SECURITY_GROUP_RULE
          TOKEN=$(
            echo $(
              curl -X POST "https://iam.cloud.ibm.com/identity/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN" -u bx:bx
              ) | jq  -r .access_token
          )
          curl -X DELETE "https://$REGION.iaas.cloud.ibm.com/v1/security_groups/$SECURITY_GROUP/rules/$SECURITY_GROUP_RULE?version=2021-08-03&generation=2" -H "Authorization: $TOKEN"
        EOT
  }
  depends_on = [
    module.bootstrap_vsi, module.bootstrap_link_profile, null_resource.bootstrap_status, time_sleep.wait_60_seconds
  ]
}