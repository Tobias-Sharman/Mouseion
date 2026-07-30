variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.206.0.0/23"
}

variable "ssh_source_cidr" {
  description = "CIDR allowed to SSH and reach the API server. Restrict to your own IP/32 rather than leaving this open"
  type        = string
  default     = "0.0.0.0/0"
}

variable "master_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}
