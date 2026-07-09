pipeline {
    agent any

    environment {
        AWS_REGION       = 'ap-south-1'
        TF_IN_AUTOMATION = 'true'
    }

    options {
        ansiColor('xterm')
        timestamps()
        disableConcurrentBuilds()
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
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Dev: Validate') {
            when { branch 'dev' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Dev: Plan') {
            when { branch 'dev' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Dev: Apply') {
            when { branch 'dev' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/dev') {
                        sh 'terraform apply -auto-approve tfplan'
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
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Main: Validate') {
            when { branch 'main' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Main: Plan') {
            when { branch 'main' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Main: Approval') {
            when { branch 'main' }
            steps {
                input(message: 'Approve Terraform Apply to MAIN (Production)?', ok: 'Approve')
            }
        }

        stage('Main: Apply') {
            when { branch 'main' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir('Environments/main') {
                        sh 'terraform apply -auto-approve tfplan'
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
