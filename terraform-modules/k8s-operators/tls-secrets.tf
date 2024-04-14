resource "kubernetes_secret" "webapp" {
  metadata {
    name      = "app-server-tls"
    namespace = "${var.app_namespace}"
  }

  data = {
    "tls.crt" = file("${var.tls_cert_path}")
    "tls.key" = file("${var.tls_key_path}")
  }

  type = "kubernetes.io/tls"

  depends_on = [
    helm_release.nginx
  ]
}

resource "kubernetes_secret" "argocd" {
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
    helm_release.nginx
  ]
}

resource "kubernetes_secret" "monitoring" {
  metadata {
    name      = "promstack-tls"
    namespace = "${var.promstack_namespace}"
  }

  data = {
    "tls.crt" = file("${var.tls_cert_path}")
    "tls.key" = file("${var.tls_key_path}")
  }

  type = "kubernetes.io/tls"

  depends_on = [
    helm_release.nginx
  ]
}