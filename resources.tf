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
  chart      = ".terraform/modules/terraform-aws-eks-crossplane/charts/crossplane"
  depends_on = [
    kubernetes_namespace.namespace_name
  ]
}
