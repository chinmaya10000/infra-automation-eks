data "aws_iam_policy_document" "assume_irsa_role" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        principals {
            type = "Federated"
            identifiers = [module.eks.oidc_provider_arn]
        }

        condition {
            test = "StringEquals"
            variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
            values = ["system:serviceaccount:solar-system:solar-app-sa"]
        }
    }
}

resource "aws_iam_role" "ecr_irsa_role" {
    name = "${var.name}-ecr-irsa-role"
    assume_role_policy = data.aws_iam_policy_document.assume_irsa_role.json
}

resource "aws_iam_role_policy_attachment" "ecr_irsa_role_policy" {
    role       = aws_iam_role.ecr_irsa_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "kubernetes_service_account" "solar_app_sa" {
  metadata {
    name      = "solar-app-sa"
    namespace = kubernetes_namespace.solar-system.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ecr_irsa_role.arn
    }
  }

  depends_on = [module.eks, aws_iam_role_policy_attachment.ecr_irsa_role_policy, kubernetes_namespace.solar-system]
}