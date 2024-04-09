resource "helm_release" "nginx" {
  name              = var.ingress_release_name
  repository        = "https://charts.bitnami.com/bitnami"
  chart             = "nginx-ingress-controller"
  namespace         = var.ingress_namespace
  create_namespace  = true

  values = [
    <<-EOT
    controller:
      extraArgs:
        enable-ssl-passthrough: "true"
    EOT
  ]
}