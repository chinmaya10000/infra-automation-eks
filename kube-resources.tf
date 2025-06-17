provider "kubernetes" {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command = "aws"
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
}

resource "kubernetes_namespace" "solar-system" {
    metadata {
      name = "solar-system"
    }
}

resource "kubernetes_role" "namespace_viewer" {
    metadata {
        name = "namespace-viewer"
        namespace = "solar-system"
    }

    rule {
        api_groups = [""]
        resources = ["pods", "services", "configmaps", "secrets", "persistentvolumes"]
        verbs = ["get", "list", "watch", "describe"]
    }

    rule {
        api_groups = ["apps"]
        resources = ["deployments", "daemonsets", "statefulsets"]
        verbs = ["get", "list", "watch", "describe"]
    }
}

resource "kubernetes_role_binding" "namespace_viewer" {
    metadata {
        name = "namespace-viewer"
        namespace = "solar-system"
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "Role"
        name = "namespace-viewer"
    }

    subject {
        kind = "User"
        name = "developer"
        api_group = "rbac.authorization.k8s.io"
    }
}

resource "kubernetes_cluster_role" "cluster_viewer" {
    metadata {
        name = "cluster-viewer"
    }

    rule {
        api_groups = [""]
        resources = ["*"]
        verbs = ["get", "list", "watch", "describe"]
    }
}

resource "kubernetes_cluster_role_binding" "cluster_viewer" {
    metadata {
        name = "cluster-viewer"
    }

    role_ref {
        kind = "ClusterRole"
        name = "cluster-viewer"
        api_group = "rbac.authorization.k8s.io"
    }

    subject {
        kind = "User"
        name = "admin"
        api_group = "rbac.authorization.k8s.io"
    }
}