# Kubernetes Master parameters
variable "folder_id" {
  description = "The ID of the folder that the Kubernetes cluster belongs to."
  type        = string
  default     = null
}

variable "region" {
  description = "The ID of the zone."
  type        = string
  default     = "eu-north1-c"
}

variable "platform_id" {
  type    = string
  default = "gpu-h100"
}

variable "k8s_subnet_CIDR" {
  description = "IP address space for k8s subnet."
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

resource "random_string" "kf_unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

variable "ssh_username" {
  description = "Username for SSH login"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Public SSH key to access the cluster nodes"
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Path to a SSH public key to access the cluster nodes"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
