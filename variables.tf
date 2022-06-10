variable "TF_PARALLELISM" {
  type        = string
  default     = "250"
  description = "Limit the number of concurrent operation."
}

variable "TF_VERSION" {
  type        = string
  default     = "1.0"
  description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable "resource_group" {
  type        = string
  default     = "default"
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed. For more information, see[Managing resource groups](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)."
}

variable "vpc_region" {
  type        = string
  description = "Name of the IBM Cloud region where the resources need to be provisioned.(Examples: us-east, us-south, etc.) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "IBM Cloud Availability Zone name(s) within the selected region where the Spectrum Scale cluster should be deployed. (Examples: [\"us-south-1\"]) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Spectrum Scale cluster. It is not possible to create multiple resources with same name. Make sure that the prefix is unique."
}

variable "vpc_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/18"]
  description = "IBM Cloud VPC address prefixes required for the VPC creation. Since our automation supports only single availability zone, so provide one cidr address prefix for vpc creation. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-configuring-address-prefixes)."
  validation {
    condition     = length(var.vpc_cidr_block) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of address prefix."
  }
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.1.0/24"]
  description = "CIDR_block required for the creation of the storage cluster private subnet. Modify when the CIDR block has already been reserved/used for other applications within the VPC or conflicts with any on-premise CIDR blocks when using a hybrid environment. Provide only one cidr_block for the creation of storage subnet."
  validation {
    condition     = length(var.vpc_storage_cluster_private_subnets_cidr_blocks) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of subnet creation."
  }
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.0.0/24"]
  description = "CIDR_block required for the creation of the compute cluster private subnet. Modify when the CIDR block has already been reserved/used for other applications within the VPC or conflicts with any on-premise CIDR blocks when using a hybrid environment. Provide only one cidr_block for the creation of compute subnet."
  validation {
    condition     = length(var.vpc_compute_cluster_private_subnets_cidr_blocks) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of subnet creation."
  }
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS domain name to be used for storage cluster."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  description = "Comma separated list of IP addresses that can access the Spectrum Scale cluster Bastion node via SSH. For the purpose of security provide the public IP address(es) assigned to the device(s) authorized to establish SSH connections. (Example : [\"169.45.117.34\"]) [Learn more](https://ipv4.icanhazip.com/)."
  validation {
    condition     = alltrue([
  for o in var.remote_cidr_blocks : !contains(["0.0.0.0/0", "0.0.0.0"], o)
])
    error_message = "For the purpose of security provide the public IP address(es) assigned to the device(s) authorized to establish SSH connections. Use https://ipv4.icanhazip.com/ to fetch the ip address of the device."
  }
}

variable "bastion_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-20-04-3-minimal-amd64-2"
  description = "Name of the image that will be used to provision the Bastion node for the Spectrum Scale cluster. Only Ubuntu stock images of any version available to the IBM Cloud account in the specific region are supported."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "The virtual server instance profile type name to be used to create the Bastion node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)"
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.bastion_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "bastion_key_pair" {
  type        = string
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Bastion and Bootstrap nodes. Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned and our automation supports only one ssh key that can be attached to bastion and bootstrap node.If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
  validation {
    condition = can(regex("^[a-z]+(-[a-z0-9]+)*$", var.bastion_key_pair))
    error_message = "Our automation code supports only one ssh key to be attached to the bastion node."
  }
}

variable "bootstrap_osimage_name" {
  type        = string
  default     = "hpcc-scale-bootstrap-v1"
  description = "Name of the custom image that you would like to use to create the Bootstrap node for the Spectrum Scale cluster. Our automation supports only the custom image that has the functionality of scale and any other custom images used without scale function will lead to the failure of cluster."
}

variable "bootstrap_vsi_profile" {
  type        = string
  default     = "bx2-8x32"
  description = "The virtual server instance profile type name to be used to create the Bootstrap node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.bootstrap_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "ibm_customer_number" {
  type        = string
  sensitive   = true
  description = "IBM Customer number to be used for BYOL (bring your own license) entitlement check."
  validation {
    condition     = trimspace(var.ibm_customer_number) != ""
    error_message = "Specified input for \"ibm_customer_number\" cannot be empty."
  }
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Spectrum Compute cluster (accessing Cluster) file system mount point. The accessingCluster is the cluster that accesses the owningCluster. [Learn more](https://www.ibm.com/docs/en/spectrum-scale/5.1.3?topic=system-mounting-remote-gpfs-file)."

  validation {
    condition     = can(regex("^\\/[a-z0-9A-Z-_]+\\/[a-z0-9A-Z-_]+$", var.compute_cluster_filesystem_mountpoint))
    error_message = "Specified value for \"compute_cluster_filesystem_mountpoint\" is not valid (valid: /gpfs/fs1)."
  }
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Spectrum Scale storage cluster (owningCluster) file system mount point. The owningCluster is the cluster that owns and serves the file system to be mounted. [Learn more](https://www.ibm.com/docs/en/spectrum-scale/5.1.3?topic=system-mounting-remote-gpfs-file)."

  validation {
    condition     = can(regex("^\\/[a-z0-9A-Z-_]+\\/[a-z0-9A-Z-_]+$", var.storage_cluster_filesystem_mountpoint))
    error_message = "Specified value for \"storage_cluster_filesystem_mountpoint\" is not valid (valid: /gpfs/fs1)."
  }
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "File system [block size](https://www.ibm.com/docs/en/spectrum-scale/5.1.3?topic=considerations-block-size). Spectrum Scale supported block sizes (in bytes) include: 256K, 512K, 1M, 2M, 4M, 8M, 16M."

  validation {
    condition     = can(regex("^256K$|^512K$|^1M$|^2M$|^4M$|^8M$|^16M$", var.filesystem_block_size))
    error_message = "Specified block size must be a valid IBM Spectrum Scale supported block sizes (256K, 512K, 1M, 2M, 4M, 8M, 16M)."
  }
}

variable "compute_vsi_profile" {
  type        = string
  default     = "bx2-2x8"
  description = "The virtual server instance profile type name to be used to create the Compute cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.compute_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "compute_cluster_key_pair" {
  type        = string
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Compute cluster nodes. Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned and our automation supports only one ssh key that can be attached to compute nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
  validation {
    condition = can(regex("^[a-z]+(-[a-z0-9]+)*$", var.compute_cluster_key_pair))
    error_message = "Our automation code supports only one ssh key to be attached to the compute node."
  }
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI username to perform system management and monitoring tasks on the compute cluster. Note: Username should be at least 4 characters, any combination of lowercase and uppercase letters."
  validation {
    condition = var.compute_cluster_gui_username == "" || (length(var.compute_cluster_gui_username) >= 4 && length(var.compute_cluster_gui_username) <= 32)
    error_message = "Specified input for \"storage_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  }
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password used for logging in to the compute cluster through the GUI. Note: Password should contain a minimum of 8 characters, and for a strong password it must be a combination of uppercase letters, lowercase letters, one number and a special character. Ensure that the password doesn't include the username."
  validation {
    condition = can(regex("^.{8,}$", var.compute_cluster_gui_password) != "") && can(regex("[0-9]{1,}", var.compute_cluster_gui_password)!= "") && can(regex("[a-z]{1,}", var.compute_cluster_gui_password) != "") && can(regex("[A-Z]{1,}",var.compute_cluster_gui_password ) != "") && can(regex("[!@#$%^&*()_+=-]{1,}", var.compute_cluster_gui_password) != "" )&& trimspace(var.compute_cluster_gui_password) != ""
    error_message = "Password should contain minimum of 8 characters and for strong password it must be a combination of uppercase letter, lowercase letter, one number and a special character. Ensure password doesn't comprise with username."
  }
}

variable "storage_vsi_profile" {
  type        = string
  default     = "bx2d-32x128"
  description = "Specify the virtual server instance profile type name to be used to create the Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."

  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d-[0-9]+x[0-9]+", var.storage_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Total number of Compute cluster instances required. A minimum of 3 nodes and a maximum of 64 nodes are supported."
  validation {
    condition     = (var.total_compute_cluster_instances >= 3 && var.total_compute_cluster_instances <= 64)
    error_message = "Specified input \"total_compute_cluster_instances\" must be in range(3, 64) Please provide the appropriate range of value."
  }
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Total number of Storage cluster instances required. A minimum of 3 nodes and a maximum of 18 nodes are supported."
  validation {
    condition     = (var.total_storage_cluster_instances >= 3 && var.total_storage_cluster_instances <= 18)
    error_message = "Specified input \"total_storage_cluster_instances\" must be in range(3, 18) Please provide the appropriate range of value."
  }
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "hpcc-scale513-rhel79-v1"
  description = "Name of the custom image that you would like to use to create the Compute cluster nodes for the Spectrum Scale cluster. Our automation supports both stock images of any version and custom image of rhel 7.9 and 8.4 version which has the scale functionality."

  validation {
    condition     = trimspace(var.compute_vsi_osimage_name) != ""
    error_message = "Specified input for \"compute_vsi_osimage_name\" is not valid."
  }
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "hpcc-scale513-rhel84-v1"
  description = "Name of the custom image that you would like to use to create the Storage cluster nodes for the Spectrum Scale cluster. Our automation supports both stock images of any version and custom image of rhel 8.4 which has the scale functionality."

  validation {
    condition     = trimspace(var.storage_vsi_osimage_name) != ""
    error_message = "Specified input \"storage_vsi_osimage_name\" is not valid."
  }
}

variable "storage_cluster_key_pair" {
  type        = string
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Storage cluster nodes. Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned and our automation supports only one ssh key that can be attached to storage nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
  validation {
    condition = can(regex("^[a-z]+(-[a-z0-9]+)*$", var.storage_cluster_key_pair))
    error_message = "Our automation code supports only one ssh key to be attached to the storage node."
  }
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI username to perform system management and monitoring tasks on the storage cluster. Note: Username should be at least 4 characters, any combination of lowercase and uppercase letters."
  validation {
    condition = var.storage_cluster_gui_username == "" || (length(var.storage_cluster_gui_username) >= 4 && length(var.storage_cluster_gui_username) <= 32)
    error_message = "Specified input for \"storage_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  }
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password used for logging in to the storage cluster through the GUI. Note: Password should contain a minimum of 8 characters, and for a strong password it must be a combination of uppercase letters, lowercase letters, one number and a special character. Ensure that the password doesn't include the username."
  validation {
    condition     = can(regex("^.{8,}$", var.storage_cluster_gui_password) != "") && can(regex("[0-9]{1,}", var.storage_cluster_gui_password) != "") && can(regex("[a-z]{1,}", var.storage_cluster_gui_password) != "") && can(regex("[A-Z]{1,}", var.storage_cluster_gui_password ) != "") && can(regex("[!@#$%^&*()_+=-]{1,}", var.storage_cluster_gui_password ) != "" )&& trimspace(var.storage_cluster_gui_password) != ""
    error_message = "Password should contain minimum of 8 characters and for strong password it must be a combination of uppercase letter, lowercase letter, one number and a special character. Ensure password doesn't comprise with username."
  }
}