variable "project_name" {
  description = "name of the project"
  type        = string
}

variable "env" {
  description = "environment"
  type        = string
}

variable "vpc_cidr" {
  description = "cidr block for the VPC"
  type        = string
}

variable "enable_vpc_dns" {
  description = "enable vpc dns"
  type        = bool
}

variable "subnet_count" {
  description = "subnet count"
  type        = number
}

variable "subnet_bits" {
  description = "number of subnet bits to use for the subnet"
  type        = number
}

variable "k8s_version" {
  description = "kubernetes version"
  type        = string
}

variable "instance_type" {
  description = "node instance type"
  type        = string
}

variable "desired_node_count" {
  description = "number of desired node count"
  type        = number
}

variable "min_node_count" {
  description = "minimum node count"
  type        = number
}

variable "max_node_count" {
  description = "maximum node count"
  type        = number
}

variable "node_disk_size" {
  description = "node disk size"
  type        = number
}

variable "ami_type" {
  description = "instance ami type"
  type        = string
}

variable "capacity_type" {
  description = "instance capacity type"
  type        = string
}

variable "aws_region" {
    description = "AWS target region"
    type        = string
}

variable "user_access_key" {
  description = "IAM user access key"
  type        = string
  sensitive   = true
}

variable "user_secret_key" {
  description = "IAM user secret key"
  type        = string
  sensitive   = true
}

variable "grafana_admin_pass" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
  sensitive   = true
}

variable "enable_powershell_interpreter" {
  description = "Enable powershell interpreter for local-exec provisioner"
  type        = bool
}

variable "app_namespace" {
  description = "Application namespace"
  type        = string
}