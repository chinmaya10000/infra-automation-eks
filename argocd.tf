# Wait for the cluster and addons to be ready
resource "time_sleep" "wait_for_cluster" {
  create_duration = "30s"

  depends_on = [ module.eks, module.eks_blueprints_addons ]
}

# Configure the ArgoCD Helm chart
resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "8.5.6"
  namespace = "argocd"
  create_namespace = true

  # ArgoCD configuration values
  values = [
    yamlencode({
        # Server configuration
        server = {
            service = {
                type = "ClusterIP"
            }
            ingress = {
                enabled = false # We'll use port-forward for access
            }
            extraArgs = [
                "--insecure" # Disable TLS for simplicity; use with caution
            ]
        }

        # Controller configuration
        controller = {
            resource = {
                requests = {
                    cpu = "100m"
                    memory = "128Mi"
                }
                limits = {
                    cpu = "500m"
                    memory = "512Mi"
                }
            }
        }

        # Repo server configuration
        repoServer = {
            resource = {
                requests = {
                    cpu = "50m"
                    memory = "64Mi"
                }
                limits = {
                    cpu = "200m"
                    memory = "256Mi"
                }
            }
        }

        # Redis configuration
        redis = {
            resource = {
                requests = {
                    cpu = "50m"
                    memory = "64Mi"
                }
                limits = {
                    cpu = "200m"
                    memory = "128Mi"
                }
            }
        }
    })
  ]

  depends_on = [ time_sleep.wait_for_cluster ]
}
# Port-forward ArgoCD server for local access
# resource "null_resource" "argocd_port_forward" {
#   provisioner "local-exec" {
#     command = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
#   }

#   depends_on = [ helm_release.argocd ]
# }
