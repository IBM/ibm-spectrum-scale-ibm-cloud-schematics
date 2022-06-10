/*
    Creates IAM trusted profile policy - Internet Service.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "trusted_profile_id" {}
variable "trusted_profile_roles" {}
variable "resource_group_id" {}

resource "ibm_iam_trusted_profile_policy" "itself" {
  profile_id = var.trusted_profile_id
  roles      = var.trusted_profile_roles

  resources {
    service           = "Internet Services"
    resource_group_id = var.resource_group_id
  }
}
