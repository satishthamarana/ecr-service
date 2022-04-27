pipeline {
  agent any
  tools {
        maven 'maven3'
        jdk 'jdk-11'
  }

  parameters {
    booleanParam (name: 'build_only', defaultValue: false, description: '', )
    choice (name: 'region', choices:['us-east-2'], description: 'AWS Region')
  }

  stages {
    stage('Setup Workspace') {
      steps {
        cleanWs()
      }
    }
    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace... */
      steps {
        dir('application') {
            checkout scm
            script {
                git_rev_count = sh(script: 'git rev-list --all --count', returnStdout: true).trim()

                version = '1.0'
                if (env.GIT_BRANCH != 'master') {
              version = '0.0'
              deploy_target = 'dev'
                } else {
              deploy_target = 'uat'
                }
                full_version = version + '.' + git_rev_count
            if (env.GIT_BRANCH != 'master' || env.GIT_BRANCH != 'develop') {
              build_only = true
            }
            }
        }
      }
    }
    stage('Build') {
      steps {
        dir('application') {
            sh 'mvn -B -DskipTests clean package'
        }
      }
    }
    stage('Docker Build') {
      steps {
        script {
            ecr_repo = '955473949192.dkr.ecr.us-east-2.amazonaws.com/dms/dmsservice'
            docker_image_tag = ecr_repo + ':' + full_version
            println("docker_image_tag: ${docker_image_tag}")
          sh("/usr/bin/docker build ${env.WORKSPACE}/application -t ${docker_image_tag}")
        }
      }
    }
    stage('Publish image to ECR') {
        steps {
          script {
            docker.withRegistry(
              'https://955473949192.dkr.ecr.us-east-2.amazonaws.com','ecr:us-east-2:aws-creds')
            //withDockerRegistry(credentialsId: 'ecr:us-east-2:aws-creds', url: 'https://955473949192.dkr.ecr.us-east-2.amazonaws.com/dms/dmsservice') {
            sh("docker push ${docker_image_tag}")
            }
          sh("docker rmi -f ${docker_image_tag}")
          }
        }
    }
    // stage('Deploy') {
    //   steps {
    //     script {
    //         if (params.build_only == false) {
    //         build job: '../Deploy/' + env.JOB_BASE_NAME, parameters: [
    //                 string(name: 'version', value: full_version),
    //                 string(name: 'environment', value: deploy_target),
    //                 string(name: 'region', value: region),
    //             ]
    //         }
    //     }
    //   }
    // }
  }
  post {
    always {
     // addShortText(full_version)
      cleanWs()
    }
  }
}
