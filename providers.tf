terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.44.2"
    }
    http = {
      source = "hashicorp/http"
      version = "3.0.1"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
