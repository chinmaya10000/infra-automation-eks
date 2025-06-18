#!/usr/bin/env groovy

pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        TF_VAR_name = "myapp-eks"
        TF_VAR_aws_region = "us-west-2"
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
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
                    sh 'terraform plan -var-file="environments/dev.tfvars" -out=tfplan'
                }
            }
        }

        stage('provision cluster') {
            steps {
                script {
                    input message: "Approve apply for dev?", ok: "Deploy"
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    input message: "Approve destroy for dev?", ok: "Destroy"
                    sh 'terraform destroy -auto-approve -var-file="environments/dev.tfvars"'
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