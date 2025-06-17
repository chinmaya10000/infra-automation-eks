locals {
  aws_k8s_role_mapping = [
    {
      rolearn = aws_iam_role.external-admin.arn
      username = "admin"
      groups = ["none"]
    },
    {
      rolearn = aws_iam_role.external-developer.arn
      username = "developer"
      groups = ["none"]
    }
  ]
}

resource "aws_iam_role" "external-admin" {
    name = "external-admin"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    AWS = var.user_for_admin_role
                }
            }
        ]
    })
}

resource "aws_iam_policy" "external-admin-policy" {
    name = "external-admin-policy"
    description = "Policy for external admin"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = ["eks:DescribeCluster"]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "external-admin-policy-attach" {
    role = aws_iam_role.external-admin.name
    policy_arn = aws_iam_policy.external-admin-policy.arn
}

resource "aws_iam_role" "external-developer" {
    name = "external-developer"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    AWS = var.user_for_developer_role
                }
            }
        ]
    })
}

resource "aws_iam_policy" "external-developer-policy" {
    name = "external-developer-policy"
    description = "Policy for external developer"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = ["eks:DescribeCluster"]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "external-developer-policy-attach" {
    role = aws_iam_role.external-developer.name
    policy_arn = aws_iam_policy.external-developer-policy.arn
}