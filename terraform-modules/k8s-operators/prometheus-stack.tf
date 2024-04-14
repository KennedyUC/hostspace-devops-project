resource "helm_release" "monitoring" {
  name              = var.promstack_release_name
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  version           = var.promstack_chart_version
  namespace         = var.promstack_namespace
  create_namespace  = true

  values = [
    <<-EOT
    prometheus:
      ingress:
        enabled: ${var.enable_ingress}
        ingressClassName: "nginx"
        hosts:
        - "prometheus.${var.domain}"      
        tls:
        - secretName: "promstack-tls"
          hosts:
          - "prometheus.${var.domain}"
    alertmanager:
      ingress:
        enabled: ${var.enable_ingress}
        ingressClassName: "nginx"
        hosts:
        - "alert.${var.domain}"       
        tls:
        - secretName: "promstack-tls"
          hosts:
          - "alert.${var.domain}"
    grafana:
      adminPassword: ${var.grafana_admin_pass}
      ingress:
        enabled: ${var.enable_ingress}
        ingressClassName: "nginx"
        hosts:
        - "grafana.${var.domain}"       
        tls:
        - secretName: "promstack-tls"
          hosts:
          - "grafana.${var.domain}"
    EOT
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_secret.monitoring
  ]
}