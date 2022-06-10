/*
    Creates IAM trusted profile.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "trusted_profile_name" {}
variable "trusted_profile_description" {}

resource "ibm_iam_trusted_profile" "itself" {
  name        = var.trusted_profile_name
  description = var.trusted_profile_description
}

output "trusted_profile_id" {
  value = ibm_iam_trusted_profile.itself.id
}
