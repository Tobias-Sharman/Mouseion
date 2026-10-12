variable "project_name" {
  description = "Name used to prefix and tag all project resources"
  type        = string
  default     = "serapeum"
}

variable "cluster_name" {
  description = "Kubernetes cluster name, used for the kubernetes.io/cluster tag the AWS cloud controller manager looks for"
  type        = string
  default     = "mouseion"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "availability_zone" {
  description = "AZ for the nodes and the private subnet, kept to one since EBS volumes are bound to one AZ"
  type        = string
  default     = "eu-west-2a"
}

variable "secondary_availability_zone" {
  description = "Second AZ, holding only a public subnet since an ALB needs subnets in at least two AZs"
  type        = string
  default     = "eu-west-2b"
}

variable "vpc_cidr" {
  description = "VPC CIDR, third octet 0 is the primary public subnet, 1 the private subnet, 2 the secondary public subnet"
  type        = string
  default     = "10.111.0.0/22"
}

variable "domain_name" {
  description = "Public domain for the website, null skips the Route 53 zone, ACM certificate, and external-dns role"
  type        = string
  default     = null
}

variable "vpn_tunnel_cidr" {
  description = "WireGuard tunnel network, the gateway takes the first host address"
  type        = string
  default     = "10.8.0.0/24"
}

variable "public_key_path" {
  description = "Path to the public key for SSH access to every instance"
  type        = string
}

variable "debian_ami_release" {
  description = "Pinned Debian 13 cloud image release, bump deliberately and replace nodes one at a time"
  type        = string
  default     = "20261001-2618"
}

variable "gateway_instance_type" {
  description = "Instance type for the WireGuard and NAT gateway"
  type        = string
  default     = "t4g.micro"
}

variable "node_instance_type" {
  description = "Instance type for the 3 controller nodes and the storage node"
  type        = string
  default     = "t4g.medium"
}
