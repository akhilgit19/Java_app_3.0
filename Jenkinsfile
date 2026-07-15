@Library('my-shared-library') _

pipeline {

    agent any

    parameters {
        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'akhilpagadapoola')
    }

    stages {

        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
            steps {
                gitCheckout(
                    branch: "main",
                    url: "https://github.com/akhilgit19/Java_app_3.0.git"
                )
            }
        }

        stage('Unit Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnTest()
                }
            }
        }

        stage('Integration Test maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static code analysis: Sonarqube') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    def SonarQubecredentialsId = 'sonarqubetoken'
                    statiCodeAnalysis(SonarQubecredentialsId)
                }
            }
        }

        stage('Quality Gate Status Check : Sonarqube') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    def SonarQubecredentialsId = 'sonarqubetoken'
                    QualityGateStatus(SonarQubecredentialsId)
                }
            }
        }

        stage('Maven Build : maven') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    mvnBuild()
                }
            }
        }

        // 📦 Upload Artifact to JFrog Artifactory
stage('Build and Add Artifact to the repo : JFrog') {
    when {
        expression { params.action == 'create' }
    }

    steps {
        script {

            // Artifactory Configuration
            def artifactoryUrl = 'http://35.170.64.84:8082/artifactory'
            def repoName = 'example-repo-local'
            def targetPath = 'kubernetes-configmap-reload/0.0.1-SNAPSHOT'
            def localArtifactPath = '/var/lib/jenkins/.m2/repository/com/minikube/sample/kubernetes-configmap-reload/0.0.1-SNAPSHOT/kubernetes-configmap-reload-0.0.1-SNAPSHOT.jar'

            // Extract filename
            def fileName = localArtifactPath.tokenize('/').last()

            // Upload URL
            def uploadUrl = "${artifactoryUrl}/${repoName}/${targetPath}/${fileName}"

            // Securely retrieve credentials from Jenkins
            withCredentials([
                usernamePassword(
                    credentialsId: 'jfrog-creds',
                    usernameVariable: 'JFROG_USER',
                    passwordVariable: 'JFROG_PASS'
                )
            ]) {

                sh """
                    echo "Uploading artifact to JFrog Artifactory..."

                    curl -v \
                        -u \$JFROG_USER:\$JFROG_PASS \
                        -T ${localArtifactPath} \
                        "${uploadUrl}"
                """
            }

            echo "Artifact uploaded successfully."
        }
    }
}

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerBuild("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

        stage('Docker Image Scan: trivy') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerImageScan("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerImagePush("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }

        stage('Docker Image Cleanup : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dockerImageCleanup("${params.ImageName}", "${params.ImageTag}", "${params.DockerHubUser}")
                }
            }
        }
    }
}

