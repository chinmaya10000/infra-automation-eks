# 🚀 Infrastructure as Code: EKS + ArgoCD + GitOps with Terraform

This repository contains Terraform code to provision and manage infrastructure on AWS, including an **Amazon EKS cluster**, **ArgoCD for GitOps**, and supporting networking and IAM resources.

We follow a modern **GitOps CI/CD model** using:
- **Terraform** for infrastructure
- **Jenkins** for CI/CD automation
- **ArgoCD** for Git-based delivery to Kubernetes
- **Best practices** for IAM, state locking, and modularity


## 🔧 Prerequisites

- Terraform >= 1.3
- AWS CLI (`aws configure`)
- `kubectl` and `helm` installed
- GitLab/GitHub repo for:
  - Application code
  - K8s manifests (e.g., Kustomize overlays)
  - Terraform code
  - ArgoCD application YAMLs

---

## 📦 What It Deploys

- 🛡️ VPC with public/private subnets, NAT Gateway
- ☸️ Amazon EKS Cluster (via module)
- 🔐 IAM roles for admin/dev access and IRSA (external secrets)
- 🧩 EKS Addons: External Secrets, Cluster Autoscaler, ALB Ingress Controller
- 🧪 ArgoCD via Helm (with GitOps repo bootstrapped)

---

## 🚀 CI/CD & GitOps Flow

1. Developer commits code → GitHub triggers Jenkins pipeline
2. Jenkins stages:
   - **Terraform Plan & Apply**
   - **Build & Push Docker Images**
   - **Update Kustomize/Manifests in GitOps Repo**
3. ArgoCD auto-syncs from GitOps repo and deploys to EKS

---
