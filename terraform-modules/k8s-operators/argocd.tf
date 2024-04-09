resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }

  depends_on = [helm_release.nginx]
}

resource "kubernetes_secret" "argocd_server_tls" {
  metadata {
    name      = "argocd-server-tls"
    namespace = "${var.argocd_namespace}"
  }

  data = {
    "tls.crt" = file("${var.tls_cert_path}")
    "tls.key" = file("${var.tls_key_path}")
  }

  type = "kubernetes.io/tls"

  depends_on = [
    helm_release.nginx,
    kubernetes_namespace.argocd]
}

resource "helm_release" "argocd" {
  name              = var.argocd_release_name
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"
  version           = var.argocd_chart_version
  namespace         = var.argocd_namespace
  create_namespace  = true

  values = [
    <<-EOT
    secret:
      argocdServerAdminPassword: ${var.argocd_admin_password}
    
    global:
      domain: "argocd.${var.domain}"

    configs:
        params:
          server.insecure: true

    certificate:
      enabled: "${var.enable_tls}"

    server:
      ingress:
        enabled: "${var.enable_ingress}"
        ingressClassName: nginx
        annotations:
          nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
        tls: "${var.enable_tls}"
    EOT
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_secret.argocd_server_tls
  ]
}