# 🚀 End-to-End GitOps CI/CD Pipeline with Jenkins, Terraform, EKS, and ArgoCD

This repository contains a Jenkins pipeline script that automates the provisioning of an EKS cluster with Terraform and deploys an application using ArgoCD. The pipeline includes validation steps to ensure your cluster and deployment are healthy and cleans up resources at the end.  
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

- 🔨 Building and tagging Docker images
- 🔒 Running **SonarQube** (static analysis) and **Trivy** (image vulnerability scanning)
- 📦 Pushing images to **private AWS ECR**
- 📝 Automatically updating `kustomization.yaml` (image tag) in GitOps repo
- 🔁 Triggering ArgoCD sync via Git commit

> **Note:**  
> Your CI pipeline should have access to both the application code repo and the GitOps repo.

---

## CD Pipeline Overview

> **This repository contains the Jenkinsfile for the CD pipeline.**  
> The CD pipeline does the following:

1. Provisions EKS and related AWS infrastructure via Terraform
2. Installs ArgoCD via Helm
3. Creates an IRSA-enabled ServiceAccount for secure ECR access
4. Deploys ArgoCD `Application` object linked to GitOps manifests repo
5. Waits for rollout status and validates service/pod readiness
6. (Optional) Destroys infra via user approval

---

## Prerequisites

- **Jenkins** with Pipeline and Credentials Binding plugins.
- **AWS CLI**, **kubectl**, and **Terraform** installed on the Jenkins agent.

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