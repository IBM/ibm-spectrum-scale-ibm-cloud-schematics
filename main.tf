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

module "scale_encryption_dns_zone" {
  count          = var.scale_encryption_enabled == true ? 1 : 0
  source         = "./resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.scale_encryption_dns_domain
  dns_service_id = module.dns_service.resource_guid[0]
  description    = "Private DNS Zone for Spectrum Scale GKLM DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "gklm_dns_permitted_network" {
  count           = var.scale_encryption_enabled == true ? 1 : 0
  source          = "./resources/ibmcloud/network/dns_permitted_network"
  permitted_count = local.vpc_create_separate_subnets == true ? 1 : 0
  instance_id     = module.dns_service.resource_guid[0]
  zone_id         = length(module.scale_encryption_dns_zone) > 0 ? module.scale_encryption_dns_zone[0].dns_zone_id : null
  vpc_crn         = module.vpc.vpc_crn
  depends_on      = [module.storage_dns_permitted_network, module.compute_dns_permitted_network]
}

# FIXME: Multi-az, Add update resolver
module "custom_resolver_storage_subnet" { # While creating the custom resolver, we are associating two subnet directly and we are not using the locations explict as there is some issue with that
  source                 = "./resources/ibmcloud/network/dns_custom_resolver"
  customer_resolver_name = format("%s-vpc-resolver", var.resource_prefix)
  instance_guid          = module.dns_service.resource_guid[0]
  description            = "Private DNS custom resolver for Spectrum Scale VPC DNS communication."
  storage_subnet_crn     = module.storage_private_subnet.subnet_crn[0]
  #compute_subnet_crn    = module.compute_private_subnet.subnet_crn[0]
  compute_subnet_crn     = local.vpc_create_separate_subnets == true ? module.compute_private_subnet.subnet_crn[0] : module.storage_private_subnet.subnet_crn[0]
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

module "schematics_ip_sg_tcp_rule" {
  source            = "./resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = local.schematics_ip
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
  tags                = local.tags
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

module "bootstrap_ssh_keys" {
  source  = "./resources/common/generate_keys"
  turn_on = true
}

locals {
  turn_on_init                  = fileexists("/tmp/.schematics/success") ? false : true
  bootstrap_path                = "/opt/IBM"
  remote_gpfs_rpms_path         = format("%s/gpfs_cloud_rpms", local.bootstrap_path)
  remote_ansible_path           = format("%s/ibm-spectrumscale-cloud-deploy", local.bootstrap_path)
  remote_terraform_path         = format("%s/ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template", local.remote_ansible_path)
  schematics_inputs_path        = "/tmp/.schematics/scale_terraform.auto.tfvars.json"
  scale_cred_path               = "/tmp/.schematics/scale_credentials.json"
  remote_inputs_path            = format("%s/terraform.tfvars.json", "/tmp")
  remote_scale_cred_path        = format("%s/scale_credentials.json", "/tmp")
  zones                         = jsonencode(var.vpc_availability_zones)
  compute_private_subnets       = jsonencode(module.compute_private_subnet.subnet_id)
  storage_private_subnets       = jsonencode(module.storage_private_subnet.subnet_id)
  scale_cluster_resource_tags   = jsonencode(local.tags)
  products                      = var.scale_encryption_enabled == false ? "scale" : "scale,gklm"
  compute_node_count            = var.total_compute_cluster_instances
  storage_node_count            = var.total_storage_cluster_instances
  encryption_node_count         = var.scale_encryption_enabled ? var.scale_encryption_server_count : "0"
  scale_cloud_install_repo_url  = "https://github.com/IBM/ibm-spectrum-scale-cloud-install"
  scale_cloud_install_repo_name = "ibm-spectrum-scale-cloud-install"
  scale_cloud_install_repo_tag  = "v2.2.0"
  scale_cloud_infra_repo_url    = "https://github.com/IBM/ibm-spectrum-scale-install-infra"
  scale_cloud_infra_repo_name   = "ibm-spectrum-scale-install-infra"
  scale_cloud_infra_repo_tag    = "ibmcloud_v2.2.0"
}

resource "local_sensitive_file" "prepare_scale_vsi_input" {
  content = <<EOT
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
    "compute_vsi_osimage_name": "${local.compute_osimage_name}",
    "compute_vsi_profile": "${var.compute_vsi_profile}",
    "using_rest_api_remote_mount": ${local.using_rest_api_remote_mount},
    "storage_cluster_gui_password": "${var.storage_cluster_gui_password}",
    "storage_cluster_gui_username": "${var.storage_cluster_gui_username}",
    "storage_cluster_key_pair": "${var.storage_cluster_key_pair}",
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
    "using_jumphost_connection": false,
    "scale_cluster_resource_tags": ${local.scale_cluster_resource_tags},
    "compute_vsi_osimage_id": "${local.compute_image_id}",
    "storage_vsi_osimage_id": "${local.storage_image_id}",
    "storage_bare_metal_osimage_id" : "${data.ibm_is_image.bare_metal_image.id}",
    "storage_bare_metal_server_profile" : "${var.storage_bare_metal_server_profile}",
    "storage_bare_metal_osimage_name" : "${var.storage_bare_metal_osimage_name}",
    "storage_type" : "${var.storage_type}",
    "scale_encryption_enabled" : "${var.scale_encryption_enabled}",
    "scale_encryption_admin_password" : "${var.scale_encryption_enabled ? var.scale_encryption_admin_password : "null"}",
    "gklm_vsi_osimage_name": "${var.scale_encryption_enabled ? local.scale_encryption_osimage_name : "null"}",
    "gklm_vsi_profile": "${var.scale_encryption_enabled ? var.scale_encryption_vsi_profile : "null"}",
    "gklm_vsi_osimage_id": "${var.scale_encryption_enabled ? local.scale_encryption_image_id : "null"}",
    "gklm_instance_key_pair": "${var.scale_encryption_enabled ? var.scale_encryption_instance_key_pair : "null"}",
    "gklm_instance_dns_service_id": "${var.scale_encryption_enabled ? module.dns_service.resource_guid[0] : "null"}",
    "gklm_instance_dns_zone_id": "${var.scale_encryption_enabled ? module.scale_encryption_dns_zone[0].dns_zone_id : "null"}",
    "gklm_instance_dns_domain": "${var.scale_encryption_enabled ? var.scale_encryption_dns_domain : "null"}",
    "create_scale_cluster": true,
    "total_compute_cluster_instances": ${local.compute_node_count},
    "total_storage_cluster_instances": ${local.storage_node_count}, 
    "total_gklm_instances": ${local.encryption_node_count}
}
EOT
  filename          = local.schematics_inputs_path
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
    module.compute_dns_zone,
    module.compute_dns_permitted_network,
    module.custom_resolver_storage_subnet
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
      "if [ ! -d ${local.remote_ansible_path}/${local.scale_cloud_install_repo_name} ]; then sudo git clone -b ${local.scale_cloud_install_repo_tag} ${local.scale_cloud_install_repo_url} ${local.remote_ansible_path}/${local.scale_cloud_install_repo_name}; fi",
      "if [ ! -d ${local.remote_ansible_path}/${local.scale_cloud_infra_repo_name}/collections/ansible_collections/ibm/spectrum_scale ]; then sudo git clone -b ${local.scale_cloud_infra_repo_tag} ${local.scale_cloud_infra_repo_url} ${local.remote_ansible_path}/${local.scale_cloud_infra_repo_name}/collections/ansible_collections/ibm/spectrum_scale; fi",
      "sudo ln -fs /usr/local/bin/ansible-playbook /usr/bin/ansible-playbook",
      "sudo cp ${local.remote_inputs_path} ${local.remote_terraform_path}",
      "export IC_API_KEY=${var.ibmcloud_api_key} && sudo -E terraform -chdir=${local.remote_terraform_path} init && sudo -E terraform -chdir=${local.remote_terraform_path} apply -parallelism=${var.TF_PARALLELISM} -auto-approve"
    ]
  }
  
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    module.bootstrap_vsi,
    module.bastion_attach_fip,
    time_sleep.wait_60_seconds,
    local_sensitive_file.prepare_scale_vsi_input
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
      "export IC_API_KEY=${self.triggers.conn_ibmcloud_api_key} && sudo -E terraform -chdir=${self.triggers.conn_remote_terraform_path} destroy -auto-approve"
    ]
  }
}
