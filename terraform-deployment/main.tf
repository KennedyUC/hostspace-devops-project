module "aws_network_setup" {
  source                        = "../terraform-modules/aws-network"
  project_name                  = var.project_name
  env                           = var.env
  subnet_count                  = var.subnet_count
  vpc_cidr                      = var.vpc_cidr
  subnet_bits                   = var.subnet_bits
  enable_vpc_dns                = var.enable_vpc_dns
}

module "aws_eks_setup" {
  source                        = "../terraform-modules/aws-eks"
  project_name                  = var.project_name
  env                           = var.env
  k8s_version                   = var.k8s_version
  instance_type                 = var.instance_type
  desired_node_count            = var.desired_node_count
  min_node_count                = var.min_node_count
  max_node_count                = var.max_node_count
  node_disk_size                = var.node_disk_size
  ami_type                      = var.ami_type
  capacity_type                 = var.capacity_type
  private_subnet_ids            = module.aws_network_setup.private_subnet_ids
  public_subnet_ids             = module.aws_network_setup.public_subnet_ids
  aws_region                    = var.aws_region
  user_access_key               = var.user_access_key
  user_secret_key               = var.user_secret_key
  enable_powershell_interpreter = var.enable_powershell_interpreter
  app_namespace                 = "school-app"
  namespaces                    = ["argocd", "monitoring", "webapp", "ingress", "sealed-secret", "school-app"]

  depends_on = [module.aws_network_setup]
}

module "k8s_operators_setup" {
  source                        = "../terraform-modules/k8s-operators"
  app_namespace                 = "school-app"
  argocd_namespace              = "argocd"
  ingress_namespace             = "nginx-ingress"
  promstack_namespace           = "monitoring"
  sealed_secret_namespace       = "sealed-secret"
  argocd_release_name           = "argocd"
  ingress_release_name          = "nginx-ingress"
  promstack_release_name        = "monitoring"
  sealed_secret_release         = "sealed-secret"
  argocd_chart_version          = "6.7.3"
  promstack_chart_version       = "57.2.0"
  domain                        = "kennweb.tech"
  enable_tls                    = true
  enable_ingress                = true
  tls_cert_path                 = "../.certs/tls.crt"
  tls_key_path                  = "../.certs/tls.key"
  grafana_admin_pass            = var.grafana_admin_pass
  argocd_admin_password         = var.argocd_admin_password

  depends_on = [module.aws_eks_setup]
}