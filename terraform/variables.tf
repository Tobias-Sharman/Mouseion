variable "project_name" {
  description = "Name used to prefix and tag all project resources"
  type        = string
  default     = "serapeum"
}

variable "master_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.master_count % 2 == 1
    error_message = "master_count must be odd, since etcd requires an odd number of members for quorum."
  }
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.111.0.0/23"
}

variable "master_instance_type" {
  description = "Instance type for the control plane node(s)"
  type        = string
  default     = "t3.small"
}

variable "web_instance_type" {
  description = "Instance type for the web node"
  type        = string
  default     = "t3.small"
}

variable "db_instance_type" {
  description = "Instance type for the DB node"
  type        = string
  default     = "t3.small"
}

variable "public_key_path" {
  description = "Path to the public key for cluster SSH access"
  type        = string
}

variable "vpn_tunnel_cidr" {
  description = "CIDR block for the WireGuard tunnel network"
  type        = string
  default     = "10.8.0.0/24"
}

variable "vpn_instance_type" {
  description = "Defaults to t3.micro for portability, but for lower cost t3.nano can be used but is untested"
  type        = string
  default     = "t3.micro"
}

variable "pod_cidr" {
  description = "CIDR block for the whole cluster's pod network. Third octet is a group index, one /24 per worker node in increasing order starting at 1 (group 0 is reserved for service_cluster_ip_range), fourth octet indexes members (pod IPs) within that node's group"
  type        = string
  default     = "10.206.0.0/16"
}
