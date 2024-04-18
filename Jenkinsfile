pipeline {
    agent any // This will allow the pipeline to run on any available agent

    // Define environment variables for Azure credentials
    environment {
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout from a Git repository; credentials may be needed if it's private
                git(url: 'https://github.com/adambaksa/LB.git', credentialsId: '9e6fe432-19e5-420c-8e6f-f2c02d8c7914')
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initializing Terraform; ensure Terraform is installed on the Jenkins agent
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Running Terraform plan to create an execution plan
                    sh 'terraform plan -out=terraform.tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Applying the Terraform plan
                    sh 'terraform apply -auto-approve terraform.tfplan'
                }
            }
        }
    }

    post {
    always {
        node {
            script {
                sh 'rm -f terraform.tfplan'
            }
            echo 'Pipeline execution is complete.'
        }
    }
}
