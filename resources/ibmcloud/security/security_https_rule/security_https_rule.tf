/*
    Creates TCP specific security group rule.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "turn_on" {}
variable "security_group_id" {}
variable "sg_direction" {}
variable "remote_ip_addr" {}

resource "ibm_is_security_group_rule" "itself" {
  count     = tobool(var.turn_on) == true ? length(var.remote_ip_addr) : 0
  group     = var.security_group_id
  direction = var.sg_direction
  remote    = var.remote_ip_addr[count.index]

  tcp {
    port_min = 443
    port_max = 443
  }
}

output "security_rule_id" {
  value = ibm_is_security_group_rule.itself[*].id
}
