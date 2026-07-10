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

        // ─── DEV BRANCH ───────────────────────────────────────────────────────

        stage('Dev: Init') {
            when { branch 'dev' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Dev: Validate') {
            when {
                allOf {
                    branch 'dev'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Dev: Plan') {
            when {
                allOf {
                    branch 'dev'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Dev: Apply') {
            when {
                allOf {
                    branch 'dev'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Dev: Destroy Approval') {
            when {
                allOf {
                    branch 'dev'
                    expression { params.DESTROY }
                }
            }
            steps {
                input(message: 'Are you sure you want to DESTROY all DEV resources?', ok: 'Yes, Destroy')
            }
        }

        stage('Dev: Destroy') {
            when {
                allOf {
                    branch 'dev'
                    expression { params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }

        // ─── MAIN BRANCH ──────────────────────────────────────────────────────

        stage('Main: Init') {
            when { branch 'main' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Main: Validate') {
            when {
                allOf {
                    branch 'main'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Main: Plan') {
            when {
                allOf {
                    branch 'main'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Main: Approval') {
            when {
                allOf {
                    branch 'main'
                    expression { !params.DESTROY }
                }
            }
            steps {
                input(message: 'Approve Terraform Apply to MAIN (Production)?', ok: 'Approve')
            }
        }

        stage('Main: Apply') {
            when {
                allOf {
                    branch 'main'
                    expression { !params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Main: Destroy Approval') {
            when {
                allOf {
                    branch 'main'
                    expression { params.DESTROY }
                }
            }
            steps {
                input(message: 'Are you sure you want to DESTROY all MAIN (Production) resources?', ok: 'Yes, Destroy')
            }
        }

        stage('Main: Destroy') {
            when {
                allOf {
                    branch 'main'
                    expression { params.DESTROY }
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Aws_cred'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (env.BRANCH_NAME == 'main') {
                    sh 'rm -f Environments/main/tfplan'
                } else {
                    sh 'rm -f Environments/dev/tfplan'
                }
            }
        }
        success {
            echo "Branch [${env.BRANCH_NAME}] — Pipeline completed successfully."
        }
        failure {
            echo "Branch [${env.BRANCH_NAME}] — Pipeline failed. Check the logs above."
        }
    }
}
