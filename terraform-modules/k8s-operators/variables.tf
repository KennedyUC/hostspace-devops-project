variable "argocd_release_name" {
  description   = "argocd helm chart release name"
  type          = string
}

variable "argocd_namespace" {
  description   = "namespace for argocd helm chart deployment"
  type          = string
}

variable "argocd_chart_version" {
  description   = "argocd helm chart version"
  type          = string
}

variable "domain" {
    description     = "base domain for dns records"
    type            = string
}

variable "enable_tls" {
  description   = "Enable TLS for argocd server"
  type          = bool
}

variable "enable_ingress" {
  description   = "Enable ingress for external connection to argocd server"
  type          = bool
}

variable "tls_cert_path" {
  description   = "Path to the tls certificate"
  type          = string
}

variable "tls_key_path" {
  description   = "Path to the tls private key"
  type          = string
}

variable "ingress_release_name" {
    description     = "Nginx release name for Helm deployment"
    type            = string
}

variable "ingress_namespace" {
    description     = "Namespace for Nginx Ingress Controller deployment"
    type            = string
}

variable "sealed_secret_release" {
    description     = "Namespace for Sealed Secret deployment"
    type            = string
}

variable "sealed_secret_namespace" {
    description     = "Namespace for Sealed Secret deployment"
    type            = string
}

variable "promstack_namespace" {
    description     = "Namespace for prometheus stack deployment"
    type            = string
}

variable "promstack_release_name" {
    description     = "Prometheus stack release name"
    type            = string
}

variable "promstack_chart_version" {
    description     = "Prometheus stack chart version"
    type            = string
}

variable "grafana_admin_pass" {
  description = "Grafana admin password"
  type        = string
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
}