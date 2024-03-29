output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = local.vpc_create_separate_subnets == true ? module.compute_private_subnet.subnet_id : []
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_storage_cluster_dns_service_id" {
  value       = module.dns_service.resource_guid[0]
  description = "IBM Cloud DNS storage cluster resource instance server ID."
}

output "vpc_compute_cluster_dns_service_id" {
  value       = module.dns_service.resource_guid[0]
  description = "IBM Cloud DNS compute cluster resource instance server ID."
}

output "vpc_storage_cluster_dns_zone_id" {
  value       = module.storage_dns_zone.dns_zone_id
  description = "IBM Cloud DNS storage cluster zone ID."
}

output "vpc_compute_cluster_dns_zone_id" {
  value       = module.compute_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_custom_resolver_id" {
  value       = module.custom_resolver_storage_subnet[*].custom_resolver_id
  description = "IBM Cloud DNS custom resolver ID."
}

output "ssh_command" { # This command works only if you have your id_rsa in the right location for that region
  value = "ssh -J ubuntu@${module.bastion_attach_fip.floating_ip_addr} vpcuser@${module.bootstrap_vsi.vsi_private_ip}"
  description = "SSH command that can be used to login to bootstrap node to destroy the cluster. Use the same command to ssh to any of storage/compute node but update the respective ip of the nodes in place of bootstrap node ip.(Examples: ssh -J <ubuntu@bastionip> <vpcuser@ip of storage/compute node>)"
}
