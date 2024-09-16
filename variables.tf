variable "TF_PARALLELISM" {
  type        = string
  default     = "250"
  description = "Limit the number of concurrent operation."
}

variable "TF_VERSION" {
  type        = string
  default     = "1.5"
  description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable "TF_LOG" {
  type        = string
  default     = "ERROR"
  description = "The Terraform log level used for output in the Schematics workspace."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "This is the IBM Cloud API key for the IBM Cloud account where the IBM Storage Scale cluster needs to be deployed. For more information on how to create an API key, see [Managing user API keys](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui)."
  validation {
    condition     = var.ibmcloud_api_key != ""
    error_message = "API key for IBM Cloud must be set."
  }
}

variable "resource_group" {
  type        = string
  default     = "Default"
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed. For more information, see[Managing resource groups](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)."
}

variable "vpc_name" {
  type        = string
  description = "Name of an existing VPC in which the cluster resources will be deployed. If no value is given, then a new VPC will be provisioned for the cluster. [Learn more](https://cloud.ibm.com/docs/vpc). If your VPC has an existing DNS service ensure the name of the DNS Service ends with prefix scale-scaledns [Example: cluster-name-scale-scaledns]"
  default     = null
}

variable "vpc_compute_subnet" {
  type        = string
  description = "Name of an existing subnet for compute nodes. If no value is given, a new subnet will be created"
  default     = null
}

variable "vpc_storage_subnet" {
  type        = string
  description = "Name of an existing subnet for storage nodes. If no value is given, a new subnet will be created"
  default     = null
}

variable "vpc_protocol_subnet" {
  type        = string
  description = "Name of an existing subnet for protocol nodes. If no value is given, a new subnet will be created"
  default     = null
}

variable "vpc_dns_service_name" {
  type        = string
  description = "Name of an existing dns resource instance. If no value is given, a new dns resource instance will be created"
  default     = null
}

variable "vpc_dns_custom_resolver_name" {
  type        = string
  description = "Name of an existing dns custom resolver. If no value is given, a new dns custom resolver will be created"
  default     = null
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "IBM Cloud availability zone names within the selected region where the Storage Scale cluster should be deployed.For the current release, the solution supports only a single availability zone.For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

variable "resource_prefix" {
  type        = string
  default     = "storage-scale"
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Storage Scale cluster. Make sure that the prefix is unique since you cannot create multiple resources with the same name. The maximum length of supported characters is 64."
}

variable "vpc_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/18"]
  description = "IBM Cloud VPC address prefixes that are needed for VPC creation. Since the solution supports only a single availability zone, provide one CIDR address prefix for VPC creation. For more information, see [Bring your own subnet](https://cloud.ibm.com/docs/vpc?topic=vpc-configuring-address-prefixes)."
  validation {
    condition     = length(var.vpc_cidr_block) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of address prefix."
  }
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.16.0/24"]
  description = "The CIDR block that's required for the creation of the storage cluster private subnet. Modify the CIDR block if it has already been reserved or used for other applications within the VPC or conflicts with any on-premises CIDR blocks when using a hybrid environment. Provide only one CIDR block for the creation of the storage subnet."
  validation {
    condition     = length(var.vpc_storage_cluster_private_subnets_cidr_blocks) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of subnet creation."
  }
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.0.0/20"]
  description = "The CIDR block that's required for the creation of the compute cluster private subnet. Modify the CIDR block if it has already been reserved or used for other applications within the VPC or conflicts with anyon-premises CIDR blocks when using a hybrid environment. Provide only one CIDR block for the creation of the compute subnet."
  validation {
    condition     = length(var.vpc_compute_cluster_private_subnets_cidr_blocks) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of subnet creation."
  }
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS Services domain name to be used for the compute cluster. Note: If an existing DNS domain is already in use, a new domain must be specified as existing domains are not supported."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS Services domain name to be used for the storage cluster. Note: If an existing DNS domain is already in use, a new domain must be specified as existing domains are not supported."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  description = "Comma-separated list of IP addresses or cidr blocks that can be access the Storage Scale cluster Bastion node through SSH. For the purpose of security, provide the public IP address(es) assigned to the device(s) authorized to establish SSH connections. (Example : [\"169.45.117.34\"])  To fetch the IP address of the device, use [https://ipv4.icanhazip.com/]."
  validation {
    condition = alltrue([
      for o in var.remote_cidr_blocks : !contains(["0.0.0.0/0", "0.0.0.0"], o)
    ])
    error_message = "For the purpose of security provide the public IP address(es) assigned to the device(s) authorized to establish SSH connections. Use https://ipv4.icanhazip.com/ to fetch the ip address of the device."
  }
  validation {
    condition = alltrue([
      for a in var.remote_cidr_blocks : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|[12]?[0-9]))?$", a))
    ])
    error_message = "Provided IP address or cidr blocks format is not valid. Check if Ip address format has comma instead of dot and there should be double quotes between each IP address range if using multiple ip ranges. For multiple IP address use format [\"169.45.117.34\",\"128.122.144.145\"]."
  }
}

variable "bastion_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-20-04-3-minimal-amd64-2"
  description = "Name of the image that will be used to provision the Bastion node for the Storage Scale cluster. Only Ubuntu stock image of any version available to the IBM Cloud account in the specific region are supported."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "The virtual server instance profile type name to be used to create the Bastion node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.bastion_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "bastion_key_pair" {
  type        = list(string)
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Bastion and Bootstrap nodes. Make Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
  validation {
    condition     = alltrue([for key in var.bastion_key_pair : can(regex("^[a-z]+(-[a-z0-9]+)*$", key))])
    error_message = "Our automation code supports multi ssh keys and should follow above patteren to be attached to the bastion node."
  }
}

variable "bootstrap_osimage_name" {
  type        = string
  default     = "hpcc-scale-bootstrap-v2-4-0"
  description = "Name of the custom image that you would like to use to create the Bootstrap node for the Storage Scale cluster. The solution supports only the default custom image that has been provided."
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

variable "management_vsi_profile" {
  type        = string
  default     = "bx2-8x32"
  description = "The virtual server instance profile type name to be used to create the Management node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.management_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "ibm_customer_number" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The IBM Customer Number (ICN) that is used for the Bring Your Own License (BYOL) entitlement check. Note: An ICN is not required if the storage_type selected is evaluation. For more information on how to find your ICN, see [What is my IBM Customer Number (ICN)?](https://www.ibm.com/support/pages/what-my-ibm-customer-number-icn)."
  validation {
    condition     = can(regex("^[0-9A-Za-z]*$", var.ibm_customer_number))
    error_message = "The IBM customer number input value cannot have special characters."
  }
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessing Cluster) file system mount point. The accessingCluster is the cluster that accesses the owningCluster. For more information, see [Mounting a remote GPFS file system](https://www.ibm.com/docs/en/storage-scale/5.1.9?topic=system-mounting-remote-gpfs-file)."
  validation {
    condition     = var.compute_cluster_filesystem_mountpoint == "" || can(regex("^\\/([a-z0-9A-Z-_]+\\/)?([a-z0-9A-Z-_]+\\/)?[a-z0-9A-Z-_]+$", var.compute_cluster_filesystem_mountpoint))
    error_message = "Specified value for \"compute_cluster_filesystem_mountpoint\" is not valid (valid: /fs1, /ibm/gpfs/fs1, /ibm/gpfs/cd1)."
  }
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage Scale storage cluster (owningCluster) file system mount point. The owningCluster is the cluster that owns and serves the file system to be mounted. For information, see[Mounting a remote GPFS file system](https://www.ibm.com/docs/en/storage-scale/5.1.9?topic=system-mounting-remote-gpfs-file)."
  validation {
    condition     = can(regex("^\\/([a-z0-9A-Z-_]+\\/)?([a-z0-9A-Z-_]+\\/)?[a-z0-9A-Z-_]+$", var.storage_cluster_filesystem_mountpoint))
    error_message = "Specified value for \"storage_cluster_filesystem_mountpoint\" is not valid (valid: /fs1, /ibm/gpfs/fs1, /ibm/gpfs/cd1)."
  }
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "File system [block size](https://www.ibm.com/docs/en/storage-scale/5.1.9?topic=considerations-block-size). Storage Scale supported block sizes (in bytes) include: 256K, 512K, 1M, 2M, 4M, 8M, 16M."

  validation {
    condition     = can(regex("^256K$|^512K$|^1M$|^2M$|^4M$|^8M$|^16M$", var.filesystem_block_size))
    error_message = "Specified block size must be a valid IBM Storage Scale supported block sizes (256K, 512K, 1M, 2M, 4M, 8M, 16M)."
  }
}

variable "compute_vsi_profile" {
  type        = string
  default     = "bx2-2x8"
  description = "The virtual server instance profile type name to be used to create the compute cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.compute_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "compute_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Compute cluster nodes. Make sure that the SSH key is present in the same resource group and region where the cluster is provisioned. The solution supports only one ssh key that can be attached to compute nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  default     = ""
  description = "GUI username to perform system management and monitoring tasks on the compute cluster. The Username should be at least 4 characters, (any combination of lowercase and uppercase letters)."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The compute cluster GUI password is used for logging in to the compute cluster through the GUI. The password should contain a minimum of 8 characters.  For a strong password, use a combination of uppercase and lowercase letters, one number and a special character. Make sure that the password doesn't contain the username and it should not start with a special character."
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
  default     = 0
  description = "The number of compute cluster instances you can provision ranges from a minimum of 3 to a maximum of 64 nodes. You may specify a count of 0 if no compute nodes are needed."
  validation {
    condition     = (var.total_compute_cluster_instances >= 3 && var.total_compute_cluster_instances <= 64 || var.total_compute_cluster_instances == 0)
    error_message = "Specified input \"total_compute_cluster_instances\" must be in range(3, 64) or it can be 0. Please provide the appropriate range of value."
  }
}

variable "total_storage_cluster_instances" { # The validation from the variable has been removed because we want validation to be performed for two different use case i.e.(Persistent and Scratch) both of them are done at main.tf file
  type        = number
  default     = 2
  description = "Total number of storage cluster instances that you need to provision. The total storage cluster instances must be an even number in range of 2 to 64."
  validation {
    condition     = (var.total_storage_cluster_instances % 2 == 0 && (var.total_storage_cluster_instances >= 2 && var.total_storage_cluster_instances <= 64))
    error_message = "Specified input \"total_storage_cluster_instances\" must be an even number in range of 2 to 64. Please provide the appropriate value."
  }
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "hpcc-scale5201-rhel88"
  description = "Name of the image that you would like to use to create the compute cluster nodes for the IBM Storage Scale cluster. The solution supports both stock and custom images that use RHEL7.9 and 8.8 versions that have the appropriate Storage Scale functionality. The supported custom images mapping for the compute nodes can be found [here](https://github.com/IBM/ibm-spectrum-scale-ibm-cloud-schematics/blob/main/image_map.tf#L15). If you'd like, you can follow the instructions for [Planning for custom images](https://cloud.ibm.com/docs/vpc?topic=vpc-planning-custom-images)to create your own custom image."

  validation {
    condition     = trimspace(var.compute_vsi_osimage_name) != ""
    error_message = "Specified input for \"compute_vsi_osimage_name\" is not valid."
  }
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "hpcc-scale5201-rhel88"
  description = "Name of the image that you would like to use to create the storage cluster nodes for the IBM Storage Scale cluster. The solution supports both stock and custom images that use RHEL8.8 version and that have the appropriate Storage Scale functionality. If you'd like, you can follow the instructions for [Planning for custom images](https://cloud.ibm.com/docs/vpc?topic=vpc-planning-custom-images) create your own custom image."

  validation {
    condition     = trimspace(var.storage_vsi_osimage_name) != ""
    error_message = "Specified input \"storage_vsi_osimage_name\" is not valid."
  }
}

variable "storage_cluster_key_pair" {
  type        = list(string)
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Storage cluster nodes. Make sure that the SSH key is present in the same resource group and region where the cluster is provisioned. The solution supports only one SSH key that can be attached to the storage nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
  validation {
    condition     = alltrue([for key in var.storage_cluster_key_pair : can(regex("^[a-z]+(-[a-z0-9]+)*$", key))])
    error_message = "Our automation code supports multi ssh keys and should follow above patteren to be attached to the storage node."
  }
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI username to perform system management and monitoring tasks on the storage cluster. Note: Username should be at least 4 characters, (any combination of lowercase and uppercase letters)."
  validation {
    condition     = var.storage_cluster_gui_username == "" || (length(var.storage_cluster_gui_username) >= 4 && length(var.storage_cluster_gui_username) <= 32)
    error_message = "Specified input for \"storage_cluster_gui_username\" is not valid. username should be greater or equal to 4 letters."
  }
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "The storage cluster GUI password is used for logging in to the storage cluster through the GUI. The password should contain a minimum of 8 characters. For a strong password, use a combination of uppercase and lowercase letters, one number, and a special character. Make sure that the password doesn't contain the username and it should not start with a special character."
  validation {
    condition     = can(regex("^.{8,}$", var.storage_cluster_gui_password) != "") && can(regex("[0-9]{1,}", var.storage_cluster_gui_password) != "") && can(regex("[a-z]{1,}", var.storage_cluster_gui_password) != "") && can(regex("[A-Z]{1,}", var.storage_cluster_gui_password) != "") && can(regex("[!@#$%^&*()_+=-]{1,}", var.storage_cluster_gui_password) != "") && trimspace(var.storage_cluster_gui_password) != "" && can(regex("^[!@#$%^&*()_+=-]", var.storage_cluster_gui_password)) == false
    error_message = "The storage cluster GUI Password should contain minimum of 8 characters and for strong password it must be a combination of uppercase letter, lowercase letter, one number and a special character. Ensure password doesn't comprise with username and it should not start with a special character."
  }
}

variable "storage_type" {
  type        = string
  default     = "scratch"
  description = "Select the Storage Scale file system deployment method. Note: The Storage Scale scratch and evaluation type deploys the Storage Scale file system on virtual server instances, and the persistent type deploys the Storage Scale file system on bare metal servers."
  validation {
    condition = can(regex("^(scratch|persistent|evaluation)$", lower(var.storage_type)))
    #condition     = contains(["scratch", "persistent"], lower(var.storage_type))
    error_message = "The solution only support scratch, evaluation, and persistent; provide any one of the value."
  }
}

variable "storage_bare_metal_server_profile" {
  type        = string
  default     = "cx2d-metal-96x192"
  description = "Specify the bare metal server profile type name to be used to create the bare metal storage nodes. For more information, see [bare metal server profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[a-z]+-[0-9]+x[0-9]+", var.storage_bare_metal_server_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "storage_bare_metal_osimage_name" {
  type        = string
  default     = "hpcc-scale5201-rhel88"
  description = "Name of the image that you would like to use to create the storage cluster nodes for the Storage Scale cluster. The solution supports only a RHEL 8.8 stock image."
  validation {
    condition     = trimspace(var.storage_bare_metal_osimage_name) != ""
    error_message = "Specified input \"storage_bare_metal_osimage_name\" is not valid."
  }
}

variable "bms_boot_drive_encryption" {
  type        = bool
  default     = false
  description = "To enable the encryption for the boot drive of bare metal server. Select true or false"
}

variable "scale_encryption_type" {
  type        = string
  default     = "null"
  description = "To enable filesystem encryption, specify either 'key_protect' or 'gklm'. If neither is specified, the default value will be 'null' and encryption is disabled"

  validation {
    condition     = var.scale_encryption_type == "key_protect" || var.scale_encryption_type == "gklm" || var.scale_encryption_type == "null"
    error_message = "Invalid value: scale_encryption_type must be 'key_protect', 'gklm', or 'null'"
  }
}

variable "scale_encryption_admin_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The password for administrative operations in KeyProtect or GKLM must be between 8 and 20 characters long. It must include at least three alphabetic characters (one uppercase and one lowercase), two numbers, and one special character from the set (~@_+:). The password should not contain the username. For more information, see [GKLM password policy](https://www.ibm.com/docs/en/sgklm/4.2?topic=manager-password-policy)"
}

variable "scale_encryption_vsi_osimage_name" {
  type        = string
  default     = "hpcc-scale-gklm4202-v2-4-0"
  description = "Specify the image name to create the GKLM server when 'scale_encryption_type' is set to 'gklm'. Only RHEL 8.8 stock images are supported."
}

variable "scale_encryption_vsi_profile" {
  type        = string
  default     = "bx2-2x8"
  description = "Specify the virtual server instance profile type to create storage nodes when 'scale_encryption_type' is set to 'gklm'. For more information, refer to Instance profiles."
}

variable "scale_encryption_server_count" {
  type        = number
  default     = 2
  description = "Specify the number of servers for a high-availability encryption setup when 'scale_encryption_type' is set to 'gklm'. A minimum of 2 servers and a maximum of 5 servers are allowed."
}

variable "scale_encryption_dns_domain" {
  type        = string
  default     = "gklmscale.com"
  description = "Specify the IBM Cloud DNS Services domain name for the GKLM cluster when 'scale_encryption_type' is set to 'gklm'. Note: If an existing DNS domain is in use, a new domain must be provided, as existing domains are not supported."
}

variable "scale_encryption_instance_key_pair" {
  type        = list(string)
  default     = null
  description = "Specify the name of the SSH key in your IBM Cloud account for connecting to the Scale Encryption keyserver nodes when scale_encryption_type is set to gklm. Ensure the SSH key is in the same resource group and region as the keyservers. Only one SSH key is supported for the keyserver nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

variable "vpc_protocol_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.17.0/24"]
  description = "The CIDR block that's required for the creation of the protocol nodes private subnet"
  validation {
    condition     = length(var.vpc_protocol_cluster_private_subnets_cidr_blocks) <= 1
    error_message = "Our Automation supports only a single AZ to deploy resources. Provide one CIDR range of subnet creation."
  }
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = "cesscale.com"
  description = "IBM Cloud DNS Services domain name to be used for the protocol nodes. Note: If an existing DNS domain is already in use, a new domain must be specified as existing domains are not supported."
}

variable "protocol_vsi_profile" {
  type        = string
  default     = "cx2-32x64"
  description = "The virtual server instance profile type name to be used to create the protocol cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.protocol_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "colocate_protocol_cluster_instances" {
  type        = bool
  default     = true
  description = "Enable it to use storage instances as protocol instances"
}

variable "total_protocol_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of protocol nodes that you need to provision. A minimum of 2 nodes and a maximum of 32 nodes are supported"
  validation {
    condition     = (var.total_protocol_cluster_instances >= 0 && var.total_protocol_cluster_instances <= 32)
    error_message = "Specified input \"total_protocol_cluster_instances\" must be in range(0, 32) or it can be 0. Please provide the appropriate range of value."
  }
}

variable "filesets" {
  type = list(object({
    mount_path = string,
    size       = number
  }))
  default     = [{ mount_path = "/mnt/scale/tools", size = 0 }, { mount_path = "/mnt/scale/data", size = 0 }]
  description = "Mount point(s) and size(s) in GB of file share(s) that can be used to customize shared file storage layout. Provide the details for up to 5 file shares."
  validation {
    condition     = length(var.filesets) <= 5
    error_message = "The custom file share count \"filesets\" must be less than or equal to 5."
  }
  validation {
    condition     = length([for mounts in var.filesets : mounts.mount_path]) == length(toset([for mounts in var.filesets : mounts.mount_path]))
    error_message = "Mount path values should not be duplicated."
  }
}

# Client Cluster Variables

variable "total_client_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of client cluster instances that you need to provision."
}

variable "client_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-8-minimal-amd64-4"
  description = "Name of the image that you would like to use to create the client cluster nodes for the IBM Storage Scale cluster. The solution supports only stock images that use RHEL8.8 version."
}

variable "client_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "The virtual server instance profile type name to be used to create the client cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.client_vsi_profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "vpc_client_cluster_dns_domain" {
  type        = string
  default     = "clntscale.com"
  description = "IBM Cloud DNS domain name to be used for client cluster. Note: If an existing DNS domain is already in use, a new domain must be specified as existing domains are not supported."
}

variable "client_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "Name of the SSH keys configured in your IBM Cloud account that is used to establish a connection to the Client cluster nodes. Make sure that the SSH key is present in the same resource group and region where the cluster is provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

## LDAP variables

variable "enable_ldap" {
  type        = bool
  default     = false
  description = "Set this option to true to enable LDAP for IBM Cloud HPC, with the default value set to false."
}

variable "ldap_basedns" {
  type        = string
  default     = "ldapscale.com"
  description = "The dns domain name is used for configuring the LDAP server. If an LDAP server is already in existence, ensure to provide the associated DNS domain name."
}

variable "ldap_server" {
  type        = string
  default     = "null"
  description = "Provide the IP address for the existing LDAP server. If no address is given, a new LDAP server will be created."
}

variable "ldap_admin_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The LDAP administrative password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required. It is important to avoid including the username in the password for enhanced security."
}

variable "ldap_user_name" {
  type        = string
  default     = ""
  description = "Custom LDAP User for performing cluster operations. Note: Username should be between 4 to 32 characters, (any combination of lowercase and uppercase letters).[This value is ignored for an existing LDAP server]"
}

variable "ldap_user_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The LDAP user password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required.It is important to avoid including the username in the password for enhanced security.[This value is ignored for an existing LDAP server]."
}

variable "ldap_instance_key_pair" {
  type        = list(string)
  default     = []
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the LDAP Server. Make sure that the SSH key is present in the same resource group and region where the LDAP Servers are provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

variable "ldap_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for LDAP virtual server instance."
}

variable "ldap_vsi_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-1"
  description = "Image name to be used for provisioning the LDAP instances. Note: Debian based OS are only supported for the LDAP feature."
}

# AFM Variables

variable "total_afm_cluster_instances" {
  type        = number
  default     = 0
  description = "Total number of instance count that you need to provision for afm nodes and enable AFM."
}

variable "afm_vsi_profile" {
  type        = string
  default     = "bx2-32x128"
  description = "The virtual instance or bare metal server instance profile type name to be used to create the AFM gateway nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui) and [bare metal server profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
  validation {
    condition     = element((split("x", var.afm_vsi_profile)), length(split("x", var.afm_vsi_profile)) - 1) >= 128
    error_message = "Minimum 128 GB of memory is needed for the AFM gateway node"
  }
}

variable "afm_cos_config" {
  type = list(object({
    cos_instance         = string,
    bucket_name          = string,
    bucket_region        = string,
    cos_service_cred_key = string,
    afm_fileset          = string,
    mode                 = string,
    bucket_type          = string,
    bucket_storage_class = string
  }))
  description = "Please provide details for the Cloud Object Storage (COS) instance, including information about the COS bucket, service credentials (HMAC key), AFM fileset, mode (such as Read-only (RO), Single writer (SW), Local updates (LU), and Independent writer (IW)), storage class (standard, vault, cold, or smart), and bucket type (single_site_location, region_location, cross_region_location). Note : The 'afm_cos_config' can contain up to 5 entries. For further details on COS bucket locations, refer to the relevant documentation https://cloud.ibm.com/docs/cloud-object-storage/basics?topic=cloud-object-storage-endpoints."
  default     =[{cos_instance="", bucket_name="", bucket_region="us-south", cos_service_cred_key="", afm_fileset="indwriter", mode="iw", bucket_storage_class="smart", bucket_type="region_location"}]
  validation {
    condition     = length([for item in var.afm_cos_config : item ]) <= 5
    error_message = "The length of \"afm_cos_config\" must be less than or equal to 5."
  }
  validation {
    condition     = alltrue([for item in var.afm_cos_config : item.mode != ""])
    error_message = "The \"mode\" field must not be empty."
  }
  validation {
    condition     = length(distinct([for item in var.afm_cos_config : item.afm_fileset])) == length(var.afm_cos_config)
    error_message = "The \"afm_fileset\" name should be unique for each AFM COS bucket relation."
  }
  validation {
    condition     = alltrue([for item in var.afm_cos_config : item.afm_fileset != ""])
    error_message = "The \"afm_fileset\" field must not be empty."
  }
  validation {
    condition     = alltrue([for config in var.afm_cos_config : !(config.bucket_type == "single_site_location") || contains(["ams03", "che01", "mil01", "mon01", "par01", "sjc04", "sng01"], config.bucket_region)])
    error_message = "When 'bucket_type' is 'single_site_location', 'bucket_region' must be one of ['ams03', 'che01', 'mil01', 'mon01', 'par01', 'sjc04', 'sng01']."
  }
  validation {
    condition     = alltrue([for config in var.afm_cos_config : !(config.bucket_type == "cross_region_location") || contains(["us", "eu", "ap"], config.bucket_region)])
    error_message = "When 'bucket_type' is 'cross_region_location', 'bucket_region' must be one of ['us', 'eu', 'ap']."
  }
  validation {
    condition     = alltrue([for config in var.afm_cos_config : !(config.bucket_type == "region_location") || contains(["us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", "jp-osa", "ca-tor", "br-sao", "eu-es"], config.bucket_region)])
    error_message = "When 'bucket_type' is 'region_location', 'bucket_region' must be one of ['us-south', 'us-east', 'eu-gb', 'eu-de', 'jp-tok', 'au-syd', 'jp-osa', 'ca-tor', 'br-sao', 'eu-es']."
  }
  validation {
  condition     = alltrue([for item in var.afm_cos_config : (item.bucket_type == "" || contains(["cross_region_location", "single_site_location", "region_location"], item.bucket_type))])
  error_message = "Each 'bucket_type' must be either empty or one of 'region_location', 'single_site_location', 'cross_region_location'."
  }
  validation {
  condition     = alltrue([for item in var.afm_cos_config : (item.bucket_storage_class == "" || (can(regex("^[a-z]+$", item.bucket_storage_class)) && contains(["smart", "standard", "cold", "vault"], item.bucket_storage_class)))])
  error_message = "Each 'bucket_storage_class' must be either empty or one of 'smart', 'standard', 'cold', or 'vault', and all in lowercase."
  }
  validation {
    condition     = alltrue([for item in var.afm_cos_config : item.bucket_region != ""])
    error_message = "The \"bucket_region\" field must not be empty."
  }
}