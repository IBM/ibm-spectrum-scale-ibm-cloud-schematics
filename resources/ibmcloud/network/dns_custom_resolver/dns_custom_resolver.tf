/*
   Add custom resolver to IBM Cloud DNS resource instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "customer_resolver_name" {}
variable "instance_guid" {}
variable "description" {}
variable "storage_subnet_crn" {}
variable "compute_subnet_crn" {}

resource "ibm_dns_custom_resolver" "itself" {
  name              = var.customer_resolver_name
  instance_id       = var.instance_guid[0]
  description       = var.description
  high_availability = false
  enabled     = true
  locations {
    subnet_crn = var.storage_subnet_crn[0]
    enabled    = true
  }
  locations {
    subnet_crn = var.compute_subnet_crn[0]
    enabled    = false
  }
}

output "custom_resolver_id" {
  value = ibm_dns_custom_resolver.itself.custom_resolver_id
}
