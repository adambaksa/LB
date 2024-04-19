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
                dir('../LB') { // Specify your directory path here
                    git branch: 'main', url: 'https://github.com/adambaksa/LB.git'
                }
            }
        }
        stage('Terraform init') {
            steps {
                dir('../LB') { // Specify your directory path here
                    script {
                        sh 'export PATH=$PATH:/opt/homebrew/bin/terraform & terraform init'
                        }
                }
            }
        }
        stage('Plan') {
            steps {
                dir('../LB') { // Specify your directory path here
                    script {
                        sh 'export PATH=$PATH:/opt/homebrew/bin/terraform & terraform plan -out tfplan'
                        sh 'export PATH=$PATH:/opt/homebrew/bin/terraform & terraform show -no-color tfplan > tfplan.txt'
                        }
                }
            }
        }
        stage('Apply / Destroy') {
            steps {
                dir('../LB') { // Specify your directory path here
                    script {
                        if (params.action == 'apply') {
                            if (!params.autoApprove) {
                                def plan = readFile 'tfplan.txt'
                                input message: "Do you want to apply the plan?",
                                parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                            }

                            sh 'export PATH=$PATH:/opt/homebrew/bin/terraform & terraform ${action} -input=false tfplan'
                        } else if (params.action == 'destroy') {
                            sh 'export PATH=$PATH:/opt/homebrew/bin/terraform & terraform ${action} --auto-approve'
                        } else {
                            error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                        }
                    }
                }
            }
        }
    }
}
