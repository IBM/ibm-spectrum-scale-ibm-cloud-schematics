/*
   Creates IBM Cloud new Subnet(s).
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}


variable "subnet_ids" {}
variable "public_gateway_id" {}

resource "ibm_is_subnet_public_gateway_attachment" "pgw_attachment" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, length(var.subnet_ids) + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.subnet_ids, idx)
    }
  }
  subnet         = each.value.subnet_id
  public_gateway = var.public_gateway_id[0]
}
