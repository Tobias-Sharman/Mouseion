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

# TODO: Fix on VPN implementation
variable "ssh_source_cidr" {
  description = "CIDR allowed to SSH and reach the API server. Restrict to your own IP/32 rather than leaving this open"
  type        = string
  default     = "0.0.0.0/0"
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
