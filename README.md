# CI/CD Pipelines for EKS, Docker, and ArgoCD GitOps

This repository contains Jenkins pipeline scripts for a complete CI/CD workflow using AWS EKS, Docker, ECR, and ArgoCD with GitOps.  
The workflow is split into two parts:

- **CI Pipeline**: Builds and pushes Docker images, and updates a GitOps repository with the new image tag.
- **CD Pipeline**: Provisions EKS infrastructure with Terraform, deploys your app via ArgoCD, and verifies the deployment.

---

## CI Pipeline Overview

> **The CI pipeline is responsible for:**  
> - Building a Docker image for your application.  
> - Pushing the image to AWS ECR.  
> - Updating the `kustomization.yaml` (or similar manifest) in a separate GitOps repository with the new image tag.  
> - (Optionally) Creating a Pull Request or pushing directly to trigger the CD pipeline.

### Typical CI Pipeline Steps

1. **Checkout Source Code**
2. **Build Docker Image**
3. **Authenticate and Push to ECR**
4. **Checkout GitOps Repository**
5. **Update `kustomization.yaml` Image Tag**
6. **Commit & Push Changes (or Create PR)**

> **Note:**  
> Your CI pipeline should have access to both the application code repo and the GitOps repo.

---

## CD Pipeline Overview

> **This repository contains the Jenkinsfile for the CD pipeline.**  
> The CD pipeline does the following:

1. Provisions an EKS cluster using Terraform.
2. Configures `kubeconfig` for the new cluster.
3. Deploys the application using ArgoCD (which tracks the GitOps repo).
4. Waits for the application to become healthy and synced.
5. Validates that pods and services are running as expected.
6. Optionally tears down (destroys) the infrastructure.

---

## Prerequisites

- **Jenkins** with Pipeline and Credentials Binding plugins.
- **AWS CLI**, **kubectl**, and **Terraform** installed on the Jenkins agent.
- **ArgoCD** installed in the target EKS cluster.
- **AWS ECR** repository for Docker images.
- **Two GitHub repositories**:
    - **App Repo**: Contains your application and Dockerfile.
    - **GitOps Repo**: Contains your Kubernetes manifests (e.g., kustomize) and is watched by ArgoCD.

---

## Required Jenkins Credentials

- `jenkins_aws_access_key_id`: AWS Access Key ID
- `jenkins_aws_secret_access_key`: AWS Secret Access Key
- `gitops-credentials`: Username/Password for GitOps repository (used by both CI and CD pipelines as needed)

---

## Sample File Structure

```
.
├── Jenkinsfile                # (CD) Jenkins pipeline script (this repo)
├── argo-application.yaml      # ArgoCD application manifest
├── environments/
│   └── dev.tfvars             # Terraform variable file
└── ...                        # Other Terraform files/resources
```

---

## Example: Updating `kustomization.yaml` in CI

The CI pipeline should update the image tag in `kustomization.yaml`, for example:

```yaml
images:
  - name: <your-app>
    newTag: <new-image-tag>
```

Use `sed`, `yq`, or similar tools to update the tag before committing to the GitOps repo.

---

## Usage

1. **Configure Jenkins credentials** as listed above.
2. **Run the CI pipeline** after pushing code changes:
    - Builds and pushes the Docker image to ECR
    - Updates `kustomization.yaml` in the GitOps repo
3. **CD pipeline (this Jenkinsfile) watches for changes in the GitOps repo**:
    - Provisions infra and deploys as described above.
    - Optionally, run manually, especially for infra changes.

---

## Customization

- Change EKS cluster name, region, and other variables in the Jenkinsfile/environment as needed.
- Adjust Terraform and Kustomize manifests for your setup.
- Adapt ArgoCD application manifest (`argo-application.yaml`) to point to your GitOps repo and app path.

---

## Troubleshooting

- **Image not updated?** Make sure CI pushes to ECR and updates the GitOps repo correctly.
- **Deployment not triggered?** Confirm ArgoCD is configured to watch the right GitOps repo/branch/path.
- **Cluster or pod issues?** Use Jenkins logs and ArgoCD UI for debugging.

---

## License

[MIT](LICENSE)