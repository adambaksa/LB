pipeline {
    agent any
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_TENANT_ID = credentials('azure-tenant-id')
    }
    
    stages {
        stage('Checkout') {
            steps {
                dir('../LB') {
                    git branch: 'main', url: 'https://github.com/adambaksa/LB.git'
                }
            }
        }
        stage('Terraform init') {
            steps {
                dir('../LB') {
                    script {
                        bat 'terraform init'
                    }
                }
            }
        }
        
        stage('Plan') {
            steps {
                dir('../LB') {
                    script {
                        bat 'terraform plan -out main.tfplan'
                        bat 'terraform show -no-color main.tfplan > tfplan.txt'
                    }
                }
            }
        }
        stage('Apply / Destroy') {
            steps {
                dir('../LB') {
                    script {
                        // Here we ensure we're using Groovy string interpolation to construct the command
                        def terraformCommand = "terraform ${params.action} -input=false main.tfplan"
                        if (params.action == 'apply') {
                            if (!params.autoApprove) {
                                def plan = readFile 'tfplan.txt'
                                input message: "Do you want to apply the plan?",
                                parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                            }
                            // Using Groovy string interpolation to pass the correct command to bat
                            bat terraformCommand
                        } else if (params.action == 'destroy') {
                            // Same approach here for the destroy action
                            bat "terraform ${params.action} --auto-approve"
                        } else {
                            error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                        }
                    }
                }
            }
        }
    }
}
