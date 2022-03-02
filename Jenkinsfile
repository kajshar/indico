pipeline {
    agent any
    environment {
        DOCKER_HUB_REPO = "kajolsharma/indico"
        //CONTAINER_NAME = "pythonflaskapp"
        
    }
    stages {
      stage('Build Image') {
            steps {
                withDockerRegistry([ credentialsId: "dockerhub_id", url: "https://index.docker.io/v1/" ]) {             
                //  Building new image
                sh 'docker image build -t $DOCKER_HUB_REPO:latest .'
                sh 'docker image tag $DOCKER_HUB_REPO:latest $DOCKER_HUB_REPO:$BUILD_NUMBER'

                //  Pushing Image to Repository
                sh 'docker push kajolsharma/indico:$BUILD_NUMBER'
                sh 'docker push kajolsharma/indico:latest'
                
                echo "Image built and pushed to repository"
                }
            }
           }
        stage('Deploy') {
            steps {
                 script{
                    //sh 'BUILD_NUMBER = ${BUILD_NUMBER}'
                    if (BUILD_NUMBER == "1") {
                        sh 'docker run --name flask-webapp -d -p 5000:5000 $DOCKER_HUB_REPO'
                    }
                    else {
                        sh 'docker stop flask-webapp'
                        sh 'docker rm flask-webapp'
                        sh 'docker run --name flask-webapp -d -p 5000:5000 $DOCKER_HUB_REPO'
                    }
                    //sh 'echo "Latest image/code deployed"'
                }
            }
        }
    }
   post {
    success {
      slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
     }
    failure {
      slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
     }
   }
}
