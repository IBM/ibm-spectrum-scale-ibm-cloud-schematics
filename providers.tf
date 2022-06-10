terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.41.0"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
