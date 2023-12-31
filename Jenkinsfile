// Pipeline to build spring boot gradle.
pipeline {
    agent any

    parameters {
      string(name: "branch", defaultValue: "main", description: "branch")
      string(name: "deploybranch", defaultValue: "main", description: "deploy branch")
      string(name: "tag", defaultValue: "latest", description: "tag")
      choice(name: "cicd", choices: "CICD\nCI\nCD", description: "CICD")
    }

    environment {
      GIT_CREDENTIAL_ID = "github_credentials_id"
      GIT_REPOSITORY_NAME = "portal-mvp-backend"
      GIT_DEPLOY_REPOSITORY_NAME = "portal-mvp-backend-deploy"
      GIT_REPOSITORY_URL = "https://github.com/seoul-immigrants/portal-mvp-backend.git"
      GIT_DEPLOY_REPOSITORY_URL = "https://github.com/seoul-immigrants/portal-mvp-backend-deploy.git"

      APP_IMAGE_REPO_CREDENTIAL_ID = "docker_credentials_id"
      IMAGE_REPO = "ehdrud1129/portal-mvp-dev-backend"
      IMAGE_TAG = "${params.tag}"
      CICD = "${params.cicd}"
    }


    stages {
        // Checkout Stage: Checkout from Git Repository
        stage("Checkout") {
          when {not {environment name: "CICD", value: "CD"}}
          steps {
            echo "Clone repository..."
            checkout([
              $class: "GitSCM",
              branches: [[name: "${params.branch}"]],
              doGenerateSubmoduleConfigurations: false,
              extensions: [[$class: "RelativeTargetDirectory", relativeTargetDir: "${GIT_REPOSITORY_NAME}"]],
              submoduleCfg: [],
              userRemoteConfigs: [[credentialsId: "${GIT_CREDENTIAL_ID}",
              url: "${GIT_REPOSITORY_URL}"]]
            ])
            checkout([
              $class: "GitSCM",
              branches: [[name: "${params.deploybranch}"]],
              doGenerateSubmoduleConfigurations: false,
              extensions: [[$class: "RelativeTargetDirectory", relativeTargetDir: "${GIT_DEPLOY_REPOSITORY_NAME}"]],
              submoduleCfg: [],
              userRemoteConfigs: [[credentialsId: "${GIT_CREDENTIAL_ID}",
              url: "${GIT_DEPLOY_REPOSITORY_URL}"]]
            ])
          }
          post {
             success { 
               echo "Successfully cloned repository."
             }
           	 failure {
               error "This pipeline stops here."
             }
          }

        }

        // Build Stage: Build application
        stage("Build Gradle") {
          when {not {environment name: "CICD", value: "CD"}}
          tools {
            jdk "openJDK17"
          }
          steps {
            echo "Bulid gradle..."
            dir("${GIT_REPOSITORY_NAME}") {
                sh "./gradlew clean build"
            }
          }
          post {
            failure {
              error "This pipeline stops here."
            }
          }
        }

        // Docker build Stage: Docker build and Push
        stage("Build Docker") {
          when {not {environment name: "CICD", value: "CD"}}
          steps {
            echo "Bulid docker..."
            script {
              env.IMAGE_LOC = env.IMAGE_REPO + ":" + "${params.tag}"
            }
            dir("${GIT_REPOSITORY_NAME}") {
              sh "cp target/*.jar ../${GIT_DEPLOY_REPOSITORY_NAME}/app.jar"
            }
            dir("${GIT_DEPLOY_REPOSITORY_NAME}") {
              // Docker build
              withCredentials([
                usernamePassword(credentialsId: "${APP_IMAGE_REPO_CREDENTIAL_ID}",
                usernameVariable: "APP_IMAGE_REPO_USERNAME",
                passwordVariable: "APP_IMAGE_REPO_PASSWORD")]) {
                sh "docker login -u $APP_IMAGE_REPO_USERNAME -p $APP_IMAGE_REPO_PASSWORD hub.docker.com"
                sh "docker build --pull --force-rm -file=Dockerfile --tag=$IMAGE_LOC ."

                // Docker push
                sh "docker push $IMAGE_LOC"

                // Remove pushed image
                sh "docker rmi $IMAGE_LOC"
              }
            }
          }
          post {
            failure {
              error "This pipeline stops here."
            }
          }
        }
    }
}
