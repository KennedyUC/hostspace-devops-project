resource "kubernetes_namespace" "secret_namespaces" {
  for_each = toset(var.secret_namespaces)
  
  metadata {
    name = each.key
  }

  depends_on = [helm_release.nginx]
}

resource "kubernetes_secret" "app-server-tls" {
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
    helm_release.nginx,
    kubernetes_namespace.secret_namespaces]
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
    kubernetes_namespace.secret_namespaces]
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
    helm_release.nginx,
    kubernetes_namespace.secret_namespaces]
}