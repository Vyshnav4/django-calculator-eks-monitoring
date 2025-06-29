// Declarative Pipeline Script
pipeline {
    agent any

    environment {
        AWS_REGION = 'YOUR_AWS_REGION' 
        ECR_REPOSITORY_NAME = 'your-ecr-repository-name' 
        AWS_ACCOUNT_ID = 'YOUR_ECR_ACCOUNT_ID' 
        GIT_REPO_URL = 'https://github.com/your-username/your-repo-name.git'
        GIT_BRANCH = 'main'
        ECR_REGISTRY_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME = "${ECR_REGISTRY_URL}/${ECR_REPOSITORY_NAME}"
    }

    stages {
        stage('Checkout from Git') {
            steps {
                script {
                    echo "Cloning repository from ${GIT_REPO_URL} on branch ${GIT_BRANCH}"
                    cleanWs()
                    git branch: env.GIT_BRANCH, url: env.GIT_REPO_URL
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    // Builds the Docker image. The '.' indicates the build context is the current directory
                    // (where the Jenkinsfile and Dockerfile reside after Git checkout).
                    docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}", ".")
                }
            }
        }

        stage('Simple Container Test') {
            steps {
                script {
                    echo "Running a simple test by starting the container..."
                    // Get a reference to the newly built Docker image
                    def customImage = docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    
                    // Run a command inside the container to verify basic functionality
                    // This example runs a Django management command to check its version.
                    // Replace with a more comprehensive test if needed (e.g., curl localhost:8000).
                    customImage.inside {
                        echo "Container started successfully. Running a basic Django check."
                        sh 'python manage.py --version'
                    }
                    echo "Container test passed."
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    echo "Explicitly logging in to Amazon ECR..."
                    // Authenticate Docker to ECR.
                    // 'withAWS' block uses the IAM role attached to the EC2 instance running Jenkins
                    // to obtain temporary credentials and securely log in Docker to ECR.
                    withAWS(region: env.AWS_REGION) {
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REGISTRY_URL}"
                    }

                    // If the login above was successful, this push will now work.
                    echo "Login successful. Pushing image ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    def image = docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    // Push the image with the Jenkins BUILD_NUMBER as a tag
                    image.push()
                    // Push the image again with the 'latest' tag for easier reference
                    image.push('latest')
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Pipeline finished. Cleaning up workspace."
                // Clean the Jenkins workspace after the pipeline execution
                cleanWs()
            }
        }
        success {
            echo 'Pipeline finished successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for errors.'
        }
    }
}