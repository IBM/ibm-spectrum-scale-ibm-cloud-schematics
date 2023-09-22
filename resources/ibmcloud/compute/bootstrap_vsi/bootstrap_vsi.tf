/*
    Creates a Bootstrap Host Instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "tags" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "vsi_subnet_id" {}
variable "vpc_zone" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "resource_grp_id" {}


data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
if grep -E -q "CentOS|Red Hat" /etc/os-release
then
    USER=vpcuser
elif grep -q "Ubuntu" /etc/os-release
then
    USER=ubuntu
fi
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "${var.vsi_meta_private_key}" > /home/$USER/.ssh/id_rsa
chmod 600 /home/vpcuser/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> home/$USER/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> /home/$USER/.ssh/config
EOF
}

resource "ibm_is_instance" "itself" {
  name    = var.vsi_name_prefix
  image   = var.vsi_image_id
  profile = var.vsi_profile
  tags    = var.tags

  primary_network_interface {
    subnet          = var.vsi_subnet_id
    security_groups = var.vsi_security_group
  }

  vpc                      = var.vpc_id
  zone                     = var.vpc_zone
  resource_group           = var.resource_grp_id
  keys                     = var.vsi_user_public_key
  user_data                = data.template_file.metadata_startup_script.rendered
  
  boot_volume {
    name = format("%s-boot-vol", var.vsi_name_prefix)
  }
}

output "vsi_id" {
  value = ibm_is_instance.itself.id
}

output "vsi_crn" {
  value = ibm_is_instance.itself.crn
}

output "vsi_private_ip" {
  value = ibm_is_instance.itself.primary_network_interface[0].primary_ip.0.address
}

output "vsi_nw_id" {
  value = ibm_is_instance.itself.primary_network_interface[0].id
}
