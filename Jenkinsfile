pipeline {
    agent any

    parameters {
        booleanParam(
            name: 'DESTROY',
            defaultValue: false,
            description: 'Check this to destroy resources instead of applying'
        )
    }

    environment {
        AWS_REGION       = 'ap-south-1'
        TF_IN_AUTOMATION = 'true'
        TF_DIR           = "Environments/${env.BRANCH_NAME}"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Init') {
            when { expression { env.BRANCH_NAME in ['dev', 'main'] } }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Validate') {
            when {
                allOf {
                    expression { env.BRANCH_NAME in ['dev', 'main'] }
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Plan') {
            when {
                allOf {
                    expression { env.BRANCH_NAME in ['dev', 'main'] }
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Approval') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'main' }
                    expression { !params.DESTROY }
                }
            }
            steps {
                input(message: 'Approve Terraform Apply to MAIN (Production)?', ok: 'Approve')
            }
        }

        stage('Apply') {
            when {
                allOf {
                    expression { env.BRANCH_NAME in ['dev', 'main'] }
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Destroy Approval') {
            when {
                allOf {
                    expression { env.BRANCH_NAME in ['dev', 'main'] }
                    expression { params.DESTROY }
                }
            }
            steps {
                script {
                    def label = env.BRANCH_NAME == 'main' ? 'MAIN (Production)' : 'DEV'
                    input(message: "Are you sure you want to DESTROY all ${label} resources?", ok: 'Yes, Destroy')
                }
            }
        }

        stage('Destroy') {
            when {
                allOf {
                    expression { env.BRANCH_NAME in ['dev', 'main'] }
                    expression { params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir(env.TF_DIR) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            sh "rm -f ${env.TF_DIR}/tfplan"
        }
        success {
            echo "Branch [${env.BRANCH_NAME}] — Pipeline completed successfully."
        }
        failure {
            echo "Branch [${env.BRANCH_NAME}] — Pipeline failed. Check the logs above."
        }
    }
}
