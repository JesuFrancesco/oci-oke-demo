provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_vcn" "generated_oci_core_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "oke-vcn-oci-oke-demo"
  dns_label      = "ociokedemo"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = "oke-igw-oci-oke-demo"
  enabled        = "true"
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "service_lb_subnet" {
  cidr_block                 = var.serviceLbSubnetCidr
  compartment_id             = var.compartment_id
  display_name               = "oke-svclbsubnet-oci-oke-demo-regional"
  dns_label                  = "lbsubd68529ff0"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_vcn.generated_oci_core_vcn.default_security_list_id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "node_subnet" {
  cidr_block                 = var.nodeSubnetCidr
  compartment_id             = var.compartment_id
  display_name               = "oke-nodesubnet-oci-oke-demo-regional"
  dns_label                  = "sub4efee855c"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_security_list.node_sec_list.id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  cidr_block                 = var.k8sApiEndpointSubnetCidr
  compartment_id             = var.compartment_id
  display_name               = "oke-k8sApiEndpoint-subnet-oci-oke-demo-regional"
  dns_label                  = "suba500f202c"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
  display_name = "oke-public-routetable-oci-oke-demo"
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.generated_oci_core_internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
}

resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = var.compartment_id
  display_name   = "oke-svclbseclist-oci-oke-demo"
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_security_list" "node_sec_list" {
  compartment_id = var.compartment_id
  display_name   = "oke-nodeseclist-oci-oke-demo"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = var.nodeSubnetCidr
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = var.k8sApiEndpointSubnetCidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = var.k8sApiEndpointSubnetCidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.k8sApiEndpointSubnetCidr
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = local.service_cidr_by_region[var.region]
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = var.nodeSubnetCidr
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = var.k8sApiEndpointSubnetCidr
    stateless = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = var.k8sApiEndpointSubnetCidr
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
  compartment_id = var.compartment_id
  display_name   = "oke-k8sApiEndpoint-oci-oke-demo"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = local.service_cidr_by_region[var.region]
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = var.nodeSubnetCidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.nodeSubnetCidr
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = var.nodeSubnetCidr
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = var.nodeSubnetCidr
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = var.nodeSubnetCidr
    stateless = "false"
  }
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }
  compartment_id = var.compartment_id
  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id            = oci_core_subnet.kubernetes_api_endpoint_subnet.id
  }
  freeform_tags = {
    "OKEclusterName" = "oci-oke-demo"
  }
  kubernetes_version = "v1.34.1"
  name               = "oci-oke-demo"
  options {
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    persistent_volume_config {
      freeform_tags = {
        "OKEclusterName" = "oci-oke-demo"
      }
    }
    service_lb_config {
      freeform_tags = {
        "OKEclusterName" = "oci-oke-demo"
      }
    }
    service_lb_subnet_ids = ["${oci_core_subnet.service_lb_subnet.id}"]
  }
  type   = "BASIC_CLUSTER"
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

data "oci_identity_availability_domains" "test_availability_domains" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "ol8_latest" {
  compartment_id = var.compartment_id

  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E5.Flex"
}


resource "oci_containerengine_node_pool" "oke_node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.generated_oci_containerengine_cluster.id
  name               = "oke-node-pool"
  kubernetes_version = "v1.34.1"

  node_shape = "VM.Standard.E5.Flex"

  node_source_details {
    image_id    = data.oci_core_images.ol8_latest.images[0].id
    source_type = "IMAGE"
  }

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  # Optionally specify SSH public key for node access
  # ssh_public_key = file(var.ssh_public_key_path)

  node_config_details {
    size = 3 # required by API, but overridden by quantity_per_subnet

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.test_availability_domains.availability_domains[0].name
      subnet_id           = oci_core_subnet.node_subnet.id
    }

    node_pool_pod_network_option_details {
      cni_type = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [
        oci_core_subnet.node_subnet.id
      ]
    }
  }
}
