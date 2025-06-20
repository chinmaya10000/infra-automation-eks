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

        stage('Deploy ArgoCD Application') {
            steps {
                script {
                    sh 'kubectl apply -f argo-application.yaml'
                }
            }
        }

        stage('ArgoCD Sync Status (optional)') {
            steps {
                echo '✅ ArgoCD application should be auto-synced. You can also validate manually via UI.'
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