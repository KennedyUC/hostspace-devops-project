resource "helm_release" "sealed-secrets" {
  name              = var.sealed_secret_release
  repository        = "https://bitnami-labs.github.io/sealed-secrets"
  chart             = "sealed-secrets"
  namespace         = var.sealed_secret_namespace
  create_namespace  = true
}