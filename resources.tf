resource "kubernetes_namespace" "namespace_name" {
  metadata {
    annotations = {
      name = "crossplane-system"
    }
    name = "crossplane-system"
  }
}

resource "helm_release" "crossplane" {
  name       = "crossplane"
  chart      = "./charts/crossplane"
  depends_on = [
    kubernetes_namespace.namespace_name
  ]
}
