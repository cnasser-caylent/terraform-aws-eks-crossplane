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

resource "kubernetes_manifest" "controller-config" {
  manifest = {
    "apiVersion" = "pkg.crossplane.io/v1alpha1"
    "kind"       = "ControllerConfig"
    "metadata" = {
      "name"      = "irsa-controllerconfig"
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::931366402038:role/aws-provider-role-tf"
      }
    }
    "spec" = {
      "args" = ["--debug"]
      "resources:" = {
        "limits" = {
          "memory" = "1Gi"
          "cpu" = "500m"
        },
        "requests" = {
          "memory" = "1Gi"
          "cpu" = "500m"
        }
      }
    }
  }
  depends_on = [
    helm_release.crossplane
  ]
}

resource "kubernetes_manifest" "provider" {
  manifest = {
    "apiVersion" = "pkg.crossplane.io/v1"
    "kind"       = "Provider"
    "metadata" = {
      "name"      = "provider-aws"
    }
    "spec" = {
      "package" = "xpkg.upbound.io/upbound/provider-aws:v0.31.0"
      "controllerConfigRef:" = {
        "name" = "irsa-controllerconfig"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.controller-config
  ]
}

resource "kubernetes_manifest" "provider-config" {
  manifest = {
    "apiVersion" = "aws.upbound.io/v1beta1"
    "kind"       = "ProviderConfig"
    "metadata" = {
      "name"      = "default"
    }
    "spec" = {
      "credentials:" = {
        "source" = "IRSA"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.provider
  ]
}
