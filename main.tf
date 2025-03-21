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

locals {
  tags                           = ["HPCC", var.resource_prefix]
  vpc_create_activity_tracker    = "false"
  vpc_activity_tracker_plan_type = "lite"
  vpc_create_separate_subnets    = true
  using_rest_api_remote_mount    = true
}

module "vpc" {
  count                         = var.vpc_name == null ? 1 : 0
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
  count        = var.vpc_name == null ? 1 : 0
  source       = "./resources/ibmcloud/network/vpc_address_prefix"
  vpc_id       = module.vpc[0].vpc_id
  address_name = format("%s-addr", var.resource_prefix)
  zones        = var.vpc_availability_zones
  cidr_block   = var.vpc_cidr_block
}

module "common_public_gw" {
  count             = var.vpc_name == null || local.existing_public_gateway_zone == "" ? 1 : 0
  source            = "./resources/ibmcloud/network/public_gw"
  public_gw_name    = format("%s-gw", var.resource_prefix)
  resource_group_id = data.ibm_resource_group.itself.id
  vpc_id            = local.cluster_vpc_id
  zones             = var.vpc_availability_zones
  tags              = local.tags
}

module "attach_existing_public_gw_exisiting_subnet" {
  count             = (var.vpc_name != null || var.vpc_storage_subnet != null) && local.existing_public_gateway_zone == "" ? 1 : 0
  source            = "./resources/ibmcloud/network/attach_existing_public_gw"
  subnet_ids        = [for subnetsdetails in data.ibm_is_subnet.existing_vpc_subnets : subnetsdetails.id]
  public_gateway_id = module.common_public_gw[0].public_gw_id
}


locals {
  cluster_vpc_id             = var.vpc_name == null ? module.vpc[0].vpc_id : data.ibm_is_vpc.existing_vpc[0].id
  cluster_storage_subnet_crn = var.vpc_name == null || var.vpc_storage_subnet == null ? module.storage_private_subnet[0].subnet_crn : [data.ibm_is_subnet.existing_storage_subnet[0].crn]
  cluster_compute_subnet_crn = local.vpc_create_separate_subnets == true ? (var.vpc_name == null || var.vpc_compute_subnet == null ? module.compute_private_subnet[0].subnet_crn : [data.ibm_is_subnet.existing_compute_subnet[0].crn]) : (var.vpc_name == null ? module.storage_private_subnet[0].subnet_crn : [data.ibm_is_subnet.existing_storage_subnet[0].crn])
  cluster_dns_service_id     = var.vpc_dns_service_name == null ? module.dns_service[0].resource_guid : [data.ibm_resource_instance.existing_dns_resource_instance[0].guid]
  cluster_custom_resolver_id = var.vpc_dns_custom_resolver_name == null ? module.custom_resolver_storage_subnet[0].custom_resolver_id : data.ibm_dns_custom_resolvers.existing_dns_custom_resolver_id[0].custom_resolvers[0].custom_resolver_id
  /*
  cluster_storage_dns_zone_id           = var.vpc_name == null && local.existing_storage_dns_zone_id == null ? module.storage_dns_zone[0].dns_zone_id : local.existing_storage_dns_zone_id
  cluster_compute_dns_zone_id           = var.vpc_name == null && local.existing_compute_dns_zone_id == null ? module.compute_dns_zone[0].dns_zone_id : local.existing_compute_dns_zone_id
  cluster_scale_encryption_dns_zone_id  = local.scale_encryption_enabled == true && var.vpc_name == null || local.existing_gklm_dns_zone_id == null ? module.scale_encryption_dns_zone[0].dns_zone_id : local.existing_gklm_dns_zone_id
  cluster_protocol_dns_zone_id          = local.scale_ces_enabled == true && var.vpc_name == null || local.existing_protocol_dns_zone_id == null ? module.protocol_dns_zone[0].dns_zone_id : local.existing_protocol_dns_zone_id
  cluster_client_dns_zone_id            = local.create_client_cluster == true && var.vpc_name == null || local.existing_client_dns_zone_id == null ? module.client_dns_zone[0].dns_zone_id : local.existing_client_dns_zone_id
  */
  cluster_gateway = local.existing_public_gateway_zone == "" ? module.common_public_gw[0].public_gw_id : local.existing_pgs
  cluster_vpc_crn = var.vpc_name == null ? module.vpc[0].vpc_crn : local.existing_vpc_crn
}

module "storage_private_subnet" {
  count             = var.vpc_name == null || var.vpc_storage_subnet == null ? 1 : 0
  source            = "./resources/ibmcloud/network/subnet"
  vpc_id            = local.cluster_vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-strg-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_storage_cluster_private_subnets_cidr_blocks
  public_gateway    = local.cluster_gateway
  depends_on        = [module.vpc_address_prefix]
  tags              = local.tags
}

module "compute_private_subnet" {
  count             = var.vpc_name == null || var.vpc_compute_subnet == null ? 1 : 0
  source            = "./resources/ibmcloud/network/subnet"
  vpc_id            = local.cluster_vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = local.vpc_create_separate_subnets == true ? [var.vpc_availability_zones[0]] : []
  subnet_name       = format("%s-comp-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_compute_cluster_private_subnets_cidr_blocks
  public_gateway    = local.cluster_gateway
  depends_on        = [module.vpc_address_prefix]
  tags              = local.tags
}

module "protocol_private_subnet" {
  count             = var.vpc_name == null || var.vpc_protocol_subnet == null && local.scale_ces_enabled == true ? 1 : 0
  source            = "./resources/ibmcloud/network/subnet"
  vpc_id            = local.cluster_vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-proto-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_protocol_cluster_private_subnets_cidr_blocks
  public_gateway    = local.cluster_gateway
  depends_on        = [module.vpc_address_prefix]
  tags              = local.tags
}

module "dns_service" {
  count                  = var.vpc_dns_service_name == null ? 1 : 0
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
  count          = 1
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_storage_cluster_dns_domain
  dns_service_id = local.cluster_dns_service_id
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
}

module "storage_dns_permitted_network" {
  count           = 1
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = local.cluster_dns_service_id
  zone_id         = module.storage_dns_zone[0].dns_zone_id
  vpc_crn         = local.cluster_vpc_crn
}

module "compute_dns_zone" {
  count          = var.total_compute_cluster_instances > 0 ? 1 : 0
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_compute_cluster_dns_domain
  dns_service_id = local.cluster_dns_service_id
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "compute_dns_permitted_network" {
  count           = var.total_compute_cluster_instances > 0 ? 1 : 0
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = local.vpc_create_separate_subnets == true ? 1 : 0
  instance_id     = local.cluster_dns_service_id
  zone_id         = module.compute_dns_zone[0].dns_zone_id
  vpc_crn         = local.cluster_vpc_crn
  depends_on      = [module.storage_dns_permitted_network]
}

module "protocol_dns_zone" {
  count          = local.scale_ces_enabled == true ? 1 : 0
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_protocol_cluster_dns_domain
  dns_service_id = local.cluster_dns_service_id
  description    = "Private DNS Zone for Spectrum Scale protocol node DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "protocol_dns_permitted_network" {
  count           = local.scale_ces_enabled == true ? 1 : 0
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = local.cluster_dns_service_id
  zone_id         = module.protocol_dns_zone[0].dns_zone_id
  vpc_crn         = local.cluster_vpc_crn
  depends_on      = [module.compute_dns_permitted_network]
}

module "client_dns_zone" {
  count          = local.create_client_cluster == true ? 1 : 0
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_client_cluster_dns_domain
  dns_service_id = local.cluster_dns_service_id
  description    = "Private DNS Zone for Spectrum Scale client node DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "client_dns_permitted_network" {
  count           = local.create_client_cluster == true ? 1 : 0
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = local.cluster_dns_service_id
  zone_id         = module.client_dns_zone[0].dns_zone_id
  vpc_crn         = local.cluster_vpc_crn
  depends_on      = [module.protocol_dns_permitted_network]
}

module "scale_encryption_dns_zone" {
  count          = local.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? 1 : 0
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = local.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? 1 : 0
  dns_domain     = var.scale_encryption_dns_domain
  dns_service_id = local.cluster_dns_service_id
  description    = "Private DNS Zone for Spectrum Scale GKLM DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "gklm_dns_permitted_network" {
  count           = local.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? 1 : 0
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = local.vpc_create_separate_subnets == true ? 1 : 0
  instance_id     = local.cluster_dns_service_id
  zone_id         = module.scale_encryption_dns_zone[0].dns_zone_id
  vpc_crn         = local.cluster_vpc_crn
  depends_on      = [module.storage_dns_permitted_network, module.compute_dns_permitted_network]
}

# FIXME: Multi-az, Add update resolver
module "custom_resolver_storage_subnet" { # While creating the custom resolver, we are associating two subnet directly and we are not using the locations explict as there is some issue with that
  count                  = var.vpc_dns_custom_resolver_name == null ? 1 : 0
  source                 = "./resources/ibmcloud/network/dns_custom_resolver"
  customer_resolver_name = format("%s-vpc-resolver", var.resource_prefix)
  instance_guid          = local.cluster_dns_service_id
  description            = "Private DNS custom resolver for Spectrum Scale VPC DNS communication."
  storage_subnet_crn     = local.cluster_storage_subnet_crn
  compute_subnet_crn     = local.cluster_compute_subnet_crn

}

module "bastion_security_group" {
  source            = "./resources/ibmcloud/security/security_group"
  turn_on           = var.bastion_sg_name == null ? true : false
  sec_group_name    = [format("%s-bastion-sg", var.resource_prefix)]
  vpc_id            = local.cluster_vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  tags              = local.tags
}

module "bastion_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  turn_on           = var.bastion_sg_name == null ? true : false
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
}

module "schematics_ip_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  turn_on           = var.bastion_sg_name == null ? true : false
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = local.schematics_ip
}

module "bastion_https_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_https_rule"
  turn_on           = var.bastion_sg_name == null ? true : false
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
}

module "bastion_sg_icmp_rule" {
  source            = "./resources/ibmcloud/security/security_icmp_rule"
  turn_on           = var.bastion_sg_name == null ? true : false
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks[0]
}

module "bastion_sg_outbound_rule" {
  source             = "./resources/ibmcloud/security/security_allow_all"
  turn_on            = var.bastion_sg_name == null ? true : false
  security_group_ids = module.bastion_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "bastion_proxy_ssh_keys" {
  source  = "./resources/common/generate_keys"
  turn_on = true
}

module "bastion_vsi" {
  source               = "./resources/ibmcloud/compute/bastion_vsi"
  vsi_name_prefix      = format("%s-bastion", var.resource_prefix)
  vpc_id               = local.cluster_vpc_id
  vpc_zone             = var.vpc_availability_zones[0]
  resource_grp_id      = data.ibm_resource_group.itself.id
  vsi_subnet_id        = local.storage_private_subnets
  comp_subnet_id       = local.enable_sec_interface == true ? local.compute_private_subnets : null
  vsi_security_group   = local.existing_sg_bastion
  vsi_profile          = var.bastion_vsi_profile
  vsi_image_id         = data.ibm_is_image.bastion_image.id
  vsi_user_public_key  = data.ibm_is_ssh_key.bastion_ssh_key[*].id
  vsi_meta_public_key  = module.bastion_proxy_ssh_keys.public_key_content
  tags                 = local.tags
  enable_sec_interface = local.enable_sec_interface
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
  turn_on           = var.bootstrap_sg_name == null ? true : false
  sec_group_name    = [format("%s-bootstrap-sg", var.resource_prefix)]
  vpc_id            = local.cluster_vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  tags              = local.tags
}

module "bootstrap_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  turn_on           = var.bootstrap_sg_name == null ? true : false
  security_group_id = module.bootstrap_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = tolist([module.bastion_security_group.sec_group_id])
}

module "bootstrap_sg_icmp_rule" {
  source            = "./resources/ibmcloud/security/security_icmp_rule"
  turn_on           = var.bootstrap_sg_name == null ? true : false
  security_group_id = module.bootstrap_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks[0]
}

module "bootstrap_sg_outbound_rule" {
  source             = "./resources/ibmcloud/security/security_allow_all"
  turn_on            = var.bootstrap_sg_name == null ? true : false
  security_group_ids = module.bootstrap_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "bootstrap_ssh_keys" {
  source  = "./resources/common/generate_keys"
  turn_on = true
}

// The resource is used to validate the existing LDAP server connection.
resource "null_resource" "validate_ldap_server_connection" {
  count = var.enable_ldap == true && var.ldap_server != "null" ? 1 : 0
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = module.bastion_proxy_ssh_keys.private_key_content
    host        = module.bastion_attach_fip.floating_ip_addr
  }
  provisioner "remote-exec" {
    inline = [
      "if openssl s_client -connect '${var.ldap_server}:389' </dev/null 2>/dev/null | grep -q 'CONNECTED'; then echo 'The connection to the existing LDAP server ${var.ldap_server} was successfully established.'; else echo 'The connection to the existing LDAP server ${var.ldap_server} failed, please establish it.'; exit 1; fi",
    ]
  }
  depends_on = [
    module.bastion_vsi
  ]
}

locals {
  turn_on_init                       = fileexists("/tmp/.schematics/success") ? false : true
  bootstrap_path                     = "/opt/IBM"
  remote_gpfs_rpms_path              = format("%s/gpfs_cloud_rpms", local.bootstrap_path)
  remote_ansible_path                = format("%s/ibm-spectrumscale-cloud-deploy", local.bootstrap_path)
  remote_terraform_path              = format("%s/ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template", local.remote_ansible_path)
  schematics_inputs_path             = "/tmp/.schematics/scale_terraform.auto.tfvars.json"
  scale_cred_path                    = "/tmp/.schematics/scale_credentials.json"
  remote_inputs_path                 = format("%s/terraform.tfvars.json", "/tmp")
  remote_scale_cred_path             = format("%s/scale_credentials.json", "/tmp")
  zones                              = jsonencode(var.vpc_availability_zones)
  compute_private_subnets            = (var.vpc_name == null || var.vpc_name != null) && var.vpc_compute_subnet == null ? tostring(element(module.compute_private_subnet[0].subnet_id, 0)) : local.existing_compute_subnet_id
  storage_private_subnets            = (var.vpc_name == null || var.vpc_name != null) && var.vpc_storage_subnet == null ? tostring(element(module.storage_private_subnet[0].subnet_id, 0)) : local.existing_storage_subnet_id
  protocol_private_subnets           = local.scale_ces_enabled ? (var.vpc_name == null || var.vpc_name != null) && var.vpc_protocol_subnet == null ? tostring(element(module.protocol_private_subnet[0].subnet_id, 0)) : local.existing_protocol_subnet_id : ""
  scale_cluster_resource_tags        = jsonencode(local.tags)
  products                           = var.scale_encryption_type == "gklm" ? "scale,gklm" : "scale"
  compute_node_count                 = var.total_compute_cluster_instances
  storage_node_count                 = var.total_storage_cluster_instances
  protocol_node_count                = var.total_protocol_cluster_instances
  client_node_count                  = var.total_client_cluster_instances
  tie_breaker_bm_server_profile      = var.tie_breaker_bare_metal_server_profile == null ? var.storage_bare_metal_server_profile : var.tie_breaker_bare_metal_server_profile
  scale_ces_enabled                  = var.total_protocol_cluster_instances > 0 ? true : false
  create_client_cluster              = var.total_client_cluster_instances > 0 ? true : false
  filesets                           = jsonencode(var.filesets)
  total_afm_cluster_instances        = var.total_afm_cluster_instances
  scale_afm_enabled                  = var.total_afm_cluster_instances > 0 ? true : false
  afm_cos_config                     = jsonencode(var.afm_cos_config)
  compute_cluster_key_pair           = jsonencode(var.compute_cluster_key_pair)
  storage_cluster_key_pair           = jsonencode(var.storage_cluster_key_pair)
  client_cluster_key_pair            = jsonencode(var.client_cluster_key_pair)
  scale_encryption_instance_key_pair = local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? jsonencode(var.scale_encryption_instance_key_pair) : jsonencode([])
  encryption_node_count              = local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? var.scale_encryption_server_count : "0"
  key_protect_instance_id            = jsonencode(var.key_protect_instance_id)
  bastion_sg_id                      = var.bastion_sg_name != null ? jsonencode(data.ibm_is_security_group.bastion_security_group[0].id) : jsonencode(module.bastion_security_group.sec_group_id)
  bootstrap_sg_id                    = var.bootstrap_sg_name != null ? jsonencode(data.ibm_is_security_group.bootstrap_security_group[0].id) : jsonencode(module.bootstrap_security_group.sec_group_id)
  strg_sg_name                       = jsonencode(var.strg_sg_name)
  comp_sg_name                       = jsonencode(var.comp_sg_name)
  gklm_sg_name                       = jsonencode(var.gklm_sg_name)
  ldap_sg_name                       = jsonencode(var.ldap_sg_name)
  existing_sg_bastion                = var.bastion_sg_name != null ? [data.ibm_is_security_group.bastion_security_group[0].id] : [module.bastion_security_group.sec_group_id]
  existing_sg_bootstrap              = var.bootstrap_sg_name != null ? [data.ibm_is_security_group.bootstrap_security_group[0].id] : [module.bootstrap_security_group.sec_group_id]
  enable_sec_interface               = local.scale_ces_enabled == false && data.ibm_is_instance_profile.compute_vsi.bandwidth[0].value >= 64000 ? true : false
  ldap_instance_key_pair             = var.enable_ldap ? jsonencode(var.ldap_instance_key_pair) : jsonencode([])
  scale_cloud_install_repo_url       = "https://github.com/IBM/ibm-spectrum-scale-cloud-install"
  scale_cloud_install_repo_name      = "ibm-spectrum-scale-cloud-install"
  scale_cloud_install_repo_tag       = "v2.8.0"
  scale_cloud_infra_repo_url         = "https://github.com/IBM/ibm-spectrum-scale-install-infra"
  scale_cloud_infra_repo_name        = "ibm-spectrum-scale-install-infra"
  scale_cloud_infra_repo_tag         = "ibmcloud_v2.8.0"
}

resource "local_sensitive_file" "prepare_scale_vsi_input" {
  content  = <<EOT
{
    "resource_group_id": "${data.ibm_resource_group.itself.id}",
    "resource_prefix": "${var.resource_prefix}",
    "vpc_region": "${local.vpc_region}",
    "vpc_availability_zones": ${local.zones},
    "vpc_id": "${local.cluster_vpc_id}",
    "vpc_compute_cluster_private_subnets": ["${local.compute_private_subnets}"],
    "vpc_storage_cluster_private_subnets": ["${local.storage_private_subnets}"],
    "vpc_custom_resolver_id": "${local.cluster_custom_resolver_id}",
    "vpc_compute_cluster_dns_service_id": "${local.cluster_dns_service_id[0]}",
    "vpc_storage_cluster_dns_service_id": "${local.cluster_dns_service_id[0]}",
    "vpc_compute_cluster_dns_zone_id": "${var.total_compute_cluster_instances > 0 ? module.compute_dns_zone[0].dns_zone_id : "null"}",
    "vpc_storage_cluster_dns_zone_id": "${module.storage_dns_zone[0].dns_zone_id}",
    "vpc_compute_cluster_dns_domain": "${var.vpc_compute_cluster_dns_domain}",
    "vpc_storage_cluster_dns_domain": "${var.vpc_storage_cluster_dns_domain}",
    "vpc_create_activity_tracker": ${local.vpc_create_activity_tracker},
    "activity_tracker_plan_type": "${local.vpc_activity_tracker_plan_type}",
    "compute_cluster_gui_username": "${var.compute_cluster_gui_username}",
    "compute_cluster_gui_password": "${var.compute_cluster_gui_password}",
    "compute_cluster_key_pair": ${local.compute_cluster_key_pair},
    "compute_vsi_osimage_name": "${local.compute_osimage_name}",
    "compute_vsi_profile": "${var.compute_vsi_profile}",
    "using_rest_api_remote_mount": ${local.using_rest_api_remote_mount},
    "storage_cluster_gui_password": "${var.storage_cluster_gui_password}",
    "storage_cluster_gui_username": "${var.storage_cluster_gui_username}",
    "storage_cluster_key_pair": ${local.storage_cluster_key_pair},
    "storage_vsi_osimage_name": "${local.storage_osimage_name}",
    "storage_vsi_profile": "${var.storage_vsi_profile}",
    "storage_cluster_filesystem_mountpoint": "${var.storage_cluster_filesystem_mountpoint}",
    "compute_cluster_filesystem_mountpoint": "${var.compute_cluster_filesystem_mountpoint}",
    "filesystem_block_size": "${var.filesystem_block_size}",
    "spectrumscale_rpms_path": "${local.remote_gpfs_rpms_path}",
    "scale_ansible_repo_clone_path": "${local.remote_ansible_path}",
    "deploy_controller_sec_group_id": ${local.bootstrap_sg_id},
    "bastion_security_group_id": ${local.bastion_sg_id},
    "bastion_instance_public_ip": null,
    "bastion_instance_id": null,
    "bastion_ssh_private_key": null,
    "using_jumphost_connection": false,
    "scale_cluster_resource_tags": ${local.scale_cluster_resource_tags},
    "compute_vsi_osimage_id": "${local.compute_image_id}",
    "storage_vsi_osimage_id": "${local.storage_image_id}",
    "storage_bare_metal_osimage_id": "${local.storage_bare_metal_image_id}",
    "storage_bare_metal_server_profile": "${var.storage_bare_metal_server_profile}",
    "tie_breaker_bare_metal_server_profile": "${local.tie_breaker_bm_server_profile}",
    "storage_bare_metal_osimage_name": "${local.storage_bare_metal_osimage_name}",
    "storage_type": "${var.storage_type}",
    "scale_encryption_enabled": "${local.scale_encryption_enabled}",
    "scale_encryption_type": "${var.scale_encryption_type}",
    "scale_encryption_admin_password": "${local.scale_encryption_enabled ? var.scale_encryption_admin_password : "null"}",
    "gklm_vsi_osimage_name": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? local.scale_encryption_osimage_name : "null"}",
    "gklm_vsi_profile": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? var.scale_encryption_vsi_profile : "null"}",
    "gklm_vsi_osimage_id": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? local.scale_encryption_image_id : "null"}",
    "gklm_instance_key_pair": ${local.scale_encryption_instance_key_pair},
    "gklm_instance_dns_service_id": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? local.cluster_dns_service_id[0] : "null"}",
    "gklm_instance_dns_zone_id": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? module.scale_encryption_dns_zone[0].dns_zone_id : "null"}",
    "gklm_instance_dns_domain": "${local.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? var.scale_encryption_dns_domain : "null"}",
    "total_compute_cluster_instances": ${local.compute_node_count},
    "total_storage_cluster_instances": ${local.storage_node_count},
    "total_gklm_instances": ${local.encryption_node_count},
    "vpc_protocol_cluster_private_subnets": ["${local.protocol_private_subnets}"],
    "protocol_vsi_profile": "${local.scale_ces_enabled ? var.protocol_server_profile : "null"}",
    "vpc_protocol_cluster_dns_service_id": "${local.scale_ces_enabled ? local.cluster_dns_service_id[0] : "null"}",
    "vpc_protocol_cluster_dns_zone_id": "${local.scale_ces_enabled ? module.protocol_dns_zone[0].dns_zone_id : "null"}",
    "vpc_protocol_cluster_dns_domain": "${local.scale_ces_enabled ? var.vpc_protocol_cluster_dns_domain : "null"}",
    "total_protocol_cluster_instances": ${local.protocol_node_count},
    "filesets": ${local.filesets},
    "total_client_cluster_instances": ${local.client_node_count},
    "client_vsi_profile": "${var.client_vsi_profile}",
    "client_vsi_osimage_name": "${var.client_vsi_osimage_name}",
    "vpc_client_cluster_dns_service_id": "${local.create_client_cluster ? local.cluster_dns_service_id[0] : "null"}",
    "vpc_client_cluster_dns_zone_id": "${local.create_client_cluster ? module.client_dns_zone[0].dns_zone_id : "null"}",
    "vpc_client_cluster_dns_domain": "${local.create_client_cluster ? var.vpc_client_cluster_dns_domain : "null"}",
    "client_cluster_key_pair": ${local.client_cluster_key_pair},
    "enable_ldap": "${var.enable_ldap}",
    "ldap_basedns": "${var.enable_ldap ? var.ldap_basedns : "null"}",
    "ldap_server": "${var.enable_ldap && var.ldap_server != "null" ? var.ldap_server : "null"}",
    "ldap_server_cert": "${var.enable_ldap && var.ldap_server != "null" ? replace(var.ldap_server_cert, "\n", "\\n") : "null"}",
    "ldap_admin_password": "${var.enable_ldap ? var.ldap_admin_password : "null"}",
    "ldap_user_name": "${var.enable_ldap && var.ldap_server == "null" ? var.ldap_user_name : "null"}",
    "ldap_user_password": "${var.enable_ldap && var.ldap_server == "null" ? var.ldap_user_password : "null"}",
    "ldap_instance_key_pair": ${local.ldap_instance_key_pair},
    "ldap_vsi_profile": "${var.ldap_vsi_profile}",
    "ldap_vsi_osimage_name": "${var.ldap_vsi_osimage_name}",
    "colocate_protocol_cluster_instances": "${var.colocate_protocol_cluster_instances}",
    "management_vsi_profile": "${var.management_vsi_profile}",
    "bms_boot_drive_encryption": "${var.bms_boot_drive_encryption}",
    "total_afm_cluster_instances": ${local.total_afm_cluster_instances},
    "afm_vsi_profile": "${var.afm_server_profile}",
    "afm_cos_config": ${local.afm_cos_config},
    "enable_sg_validation": "${var.enable_sg_validation}",
    "strg_sg_name": ${local.strg_sg_name},
    "comp_sg_name": ${local.comp_sg_name},
    "gklm_sg_name": ${local.gklm_sg_name},
    "ldap_sg_name": ${local.ldap_sg_name},
    "key_protect_instance_id": ${local.key_protect_instance_id}
}    
EOT
  filename = local.schematics_inputs_path
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
  vpc_id               = local.cluster_vpc_id
  vpc_zone             = var.vpc_availability_zones[0]
  resource_grp_id      = data.ibm_resource_group.itself.id
  vsi_subnet_id        = local.storage_private_subnets
  vsi_security_group   = local.existing_sg_bootstrap
  vsi_profile          = var.bootstrap_vsi_profile
  vsi_image_id         = local.bootstrap_image_mapping_entry_found ? local.bootstrap_image_id : data.ibm_is_image.bootstrap_image[0].id
  vsi_user_public_key  = data.ibm_is_ssh_key.bastion_ssh_key[*].id
  vsi_meta_private_key = module.bootstrap_ssh_keys.private_key_content
  vsi_meta_public_key  = module.bootstrap_ssh_keys.public_key_content
  tags                 = local.tags
  depends_on = [
    module.bastion_sg_tcp_rule,
    module.schematics_ip_sg_tcp_rule,
    module.bastion_https_tcp_rule,
    module.bastion_sg_outbound_rule,
    module.bastion_vsi,
    module.bastion_attach_fip,
    module.bootstrap_security_group,
    module.bootstrap_sg_tcp_rule,
    module.bootstrap_sg_outbound_rule,
    module.bootstrap_ssh_keys,
    module.bastion_proxy_ssh_keys,
    module.storage_private_subnet,
    module.compute_private_subnet,
    module.dns_service,
    module.storage_dns_zone,
    module.storage_dns_permitted_network,
    # module.compute_dns_zone,
    # module.compute_dns_permitted_network,
    module.custom_resolver_storage_subnet,
    null_resource.validate_ldap_server_connection,
    module.attach_existing_public_gw_exisiting_subnet
  ]
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
  depends_on      = [module.bootstrap_vsi]
}

resource "null_resource" "entitlement_check" {
  count = var.storage_type != "evaluation" ? 1 : 0
  connection {
    type                = "ssh"
    host                = module.bootstrap_vsi.vsi_private_ip
    user                = "vpcuser"
    private_key         = module.bootstrap_ssh_keys.private_key_content
    bastion_host        = module.bastion_attach_fip.floating_ip_addr
    bastion_user        = "ubuntu"
    bastion_private_key = module.bastion_proxy_ssh_keys.private_key_content
  }

  provisioner "remote-exec" {
    inline = [
      "sudo python3 /opt/IBM/cloud_entitlement/entitlement_check.py --products ${local.products} --icns ${var.ibm_customer_number}"
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [module.bootstrap_vsi, module.bastion_attach_fip]
}

resource "null_resource" "scale_resource_provisioner" {
  connection {
    type                = "ssh"
    host                = module.bootstrap_vsi.vsi_private_ip
    user                = "vpcuser"
    private_key         = module.bootstrap_ssh_keys.private_key_content
    bastion_host        = module.bastion_attach_fip.floating_ip_addr
    bastion_user        = "ubuntu"
    bastion_private_key = module.bastion_proxy_ssh_keys.private_key_content
    timeout             = "60m"
  }

  provisioner "file" {
    source      = local.schematics_inputs_path
    destination = local.remote_inputs_path
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -d ${local.remote_ansible_path}/${local.scale_cloud_install_repo_name} ]; then sudo git clone -b ${local.scale_cloud_install_repo_tag} ${local.scale_cloud_install_repo_url} ${local.remote_ansible_path}/${local.scale_cloud_install_repo_name}; fi",
      "if [ ! -d ${local.remote_ansible_path}/${local.scale_cloud_infra_repo_name}/collections/ansible_collections/ibm/spectrum_scale ]; then sudo git clone -b ${local.scale_cloud_infra_repo_tag} ${local.scale_cloud_infra_repo_url} ${local.remote_ansible_path}/${local.scale_cloud_infra_repo_name}/collections/ansible_collections/ibm/spectrum_scale; fi",
      "sudo ln -fs /usr/local/bin/ansible-playbook /usr/bin/ansible-playbook",
      "sudo cp ${local.remote_inputs_path} ${local.remote_terraform_path}",
      "export IC_API_KEY=${var.ibmcloud_api_key} && export TF_LOG=${var.TF_LOG} && sudo -E terraform -chdir=${local.remote_terraform_path} init && sudo -E terraform -chdir=${local.remote_terraform_path} apply -parallelism=${var.TF_PARALLELISM} -var 'create_scale_cluster=false' -auto-approve"
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    module.bootstrap_vsi,
    module.bastion_attach_fip,
    time_sleep.wait_60_seconds,
    local_sensitive_file.prepare_scale_vsi_input,
    null_resource.validate_ldap_server_connection
  ]
}

resource "null_resource" "scale_cluster_provisioner" {
  connection {
    type                = "ssh"
    host                = module.bootstrap_vsi.vsi_private_ip
    user                = "vpcuser"
    private_key         = module.bootstrap_ssh_keys.private_key_content
    bastion_host        = module.bastion_attach_fip.floating_ip_addr
    bastion_user        = "ubuntu"
    bastion_private_key = module.bastion_proxy_ssh_keys.private_key_content
    timeout             = "60m"
  }

  provisioner "file" {
    source      = local.schematics_inputs_path
    destination = local.remote_inputs_path
  }

  provisioner "remote-exec" {
    inline = [
      "export IC_API_KEY=${var.ibmcloud_api_key} && export TF_LOG=${var.TF_LOG} && sudo -E terraform -chdir=${local.remote_terraform_path} apply -parallelism=${var.TF_PARALLELISM} -var 'create_scale_cluster=true' -auto-approve"
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    module.bootstrap_vsi,
    module.bastion_attach_fip,
    time_sleep.wait_60_seconds,
    local_sensitive_file.prepare_scale_vsi_input,
    null_resource.scale_resource_provisioner,
    null_resource.validate_ldap_server_connection
  ]
}

resource "null_resource" "scale_cluster_destroyer" {
  triggers = {
    conn_host                  = module.bootstrap_vsi.vsi_private_ip
    conn_private_key           = module.bootstrap_ssh_keys.private_key_content
    conn_bastion_host          = module.bastion_attach_fip.floating_ip_addr
    conn_bastion_private_key   = module.bastion_proxy_ssh_keys.private_key_content
    conn_ibmcloud_api_key      = var.ibmcloud_api_key
    conn_remote_terraform_path = local.remote_terraform_path
    conn_terraform_log_level   = var.TF_LOG
  }

  connection {
    type                = "ssh"
    host                = self.triggers.conn_host
    user                = "vpcuser"
    private_key         = self.triggers.conn_private_key
    bastion_host        = self.triggers.conn_bastion_host
    bastion_user        = "ubuntu"
    bastion_private_key = self.triggers.conn_bastion_private_key
    timeout             = "60m"
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = fail
    inline = [
      "export IC_API_KEY=${self.triggers.conn_ibmcloud_api_key} && export TF_LOG=${self.triggers.conn_terraform_log_level} && sudo -E terraform -chdir=${self.triggers.conn_remote_terraform_path} destroy -auto-approve"
    ]
  }
}