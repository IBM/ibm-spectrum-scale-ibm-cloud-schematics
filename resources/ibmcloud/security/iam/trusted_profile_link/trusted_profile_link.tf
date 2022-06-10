/*
    Creates IAM trusted profile link to VSI.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "trusted_profile_id" {}
variable "target_vsi_crn" {}
variable "trusted_profile_link_name" {}

resource "ibm_iam_trusted_profile_link" "itself" {
  profile_id = var.trusted_profile_id
  cr_type    = "VSI"
  link {
    crn = var.target_vsi_crn
  }
  name = var.trusted_profile_link_name
}

output "trusted_profile_link_id" {
  value = ibm_iam_trusted_profile_link.itself.id
}
