variable "compartment_id" {
  description = "The OCID of the compartment in which to create resources."
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8sApiEndpointSubnetCidr" {
  description = "The CIDR block for the Kubernetes API Endpoint Subnet."
  type        = string
  default     = "10.0.0.0/28"
}

variable "nodeSubnetCidr" {
  description = "The CIDR block for the Node Subnet."
  type        = string
  default     = "10.0.10.0/24"
}

variable "serviceLbSubnetCidr" {
  description = "The CIDR block for the Service Load Balancer Subnet."
  type        = string
  default     = "10.0.20.0/24"
}

variable "number_of_nodes" {
  description = "The number of worker nodes in the OKE cluster."
  type        = number
  default     = 3
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
