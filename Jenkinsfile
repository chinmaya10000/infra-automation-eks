#!/usr/bin/env groovy

pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        TF_VAR_name = "myapp-eks"
        TF_VAR_aws_region = "us-east-2"
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'gitops-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh '''
                            export TF_VAR_gitops_username=$GIT_USER
                            export TF_VAR_gitops_password=$GIT_PASS
                            terraform plan -var-file="environments/dev.tfvars" -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('provision cluster') {
            steps {
                script {
                    input message: "Approve apply for dev?", ok: "Deploy"
                    withCredentials([usernamePassword(credentialsId: 'gitops-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh '''
                            export TF_VAR_gitops_username=$GIT_USER
                            export TF_VAR_gitops_password=$GIT_PASS
                            terraform apply --auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --region ${TF_VAR_aws_region} --name ${TF_VAR_name}"
                }
            }
        }

        stage('Check EKS Nodes') {
            steps {
                script {
                    echo "🔍 Checking EKS nodes..."
                    sleep(time: 10, unit: 'SECONDS')
                    def nodes = sh(script: "kubectl get nodes --no-headers || true", returnStdout: true).trim()
                    if (nodes) {
                        echo "✅ EKS nodes are ready:\n${nodes}"
                    } else {
                        error "❌ No EKS nodes found. Please check the cluster setup."
                    }
                }
            }
        }

        stage('Deploy ArgoCD Application') {
            steps {
                script {
                    sh 'kubectl apply -f argo-application.yaml'
                }
            }
        }

        stage('Check Pods and Services') {
            steps {
                script {
                    echo "⏳ Waiting briefly before checking resources..."
                    sleep(time: 15, unit: 'SECONDS')  // <-- wait for resources to settle
                    
                    echo "🔍 Checking Pods and Services in 'solar-system' namespace..."

                    def pods = sh(script: "kubectl get pods -n solar-system --no-headers || true", returnStdout: true).trim()
                    if (pods) {
                        echo "✅ Pods in 'solar-system' namespace:\n${pods}"
                    } else {
                        error "❌ No Pods found in 'solar-system' namespace."
                    }

                    def services = sh(script: "kubectl get services -n solar-system --no-headers || true", returnStdout: true).trim()
                    if (services) {
                        echo "✅ Services in 'solar-system' namespace:\n${services}"
                    } else {
                        error "❌ No Services found in 'solar-system' namespace."
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    input message: "Approve destroy for dev?", ok: "Destroy"
                    withCredentials([usernamePassword(credentialsId: 'gitops-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh '''
                            export TF_VAR_gitops_username=$GIT_USER
                            export TF_VAR_gitops_password=$GIT_PASS
                            terraform destroy -auto-approve -var-file="environments/dev.tfvars"
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed.'
        }
    }
}