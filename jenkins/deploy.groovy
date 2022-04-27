pipeline {
  agent any
  tools { 
        maven 'maven3'
        jdk 'jdk-11'
  }
  options {
	disableConcurrentBuilds()
  }
  triggers {
	pollSCM('')
  }

  parameters {
    string (name: 'version', description: 'Artifact Version')
    choice (name: 'environment', choices: ["dev", "uat", "prod"], description: 'Deployment Environment')
    choice (name: 'region', choices: ['ap-south-1'], description: 'AWS Region')
  }

  stages {
    stage('Setup Workspace') {
	    steps {
	      cleanWs()
        script {
          if (params.environment == null || params.environment.length() == 0) {
            currentBuild.result = 'ABORTED'
            error("environment param is empty")
          }

          if (params.environment == 'uat' || params.environment == 'prod') {
            if (env.GIT_BRANCH != 'master') {
              currentBuild.result = 'ABORTED'
              error("Deployment to uat or prod can only happen from master branch")
            }
          }
        }
	    }
    }
    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace... */
      steps {
	  dir("application") {
              checkout scm
          }
       }
    }
    stage('Deploy via Terraform') {
      steps {
         script {    
	       dir("application/deploy/terraform") {
		 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  sh("terraform init -backend-config=tfvars/backend_${params.environment}.tfvars -reconfigure")
	          sh("terraform plan -var app_version=${version} -var git_repo=${GIT_URL} -var git_revision=${GIT_COMMIT} -var-file=tfvars/${params.environment}.tfvars -out plan.out")
	          sh("terraform apply plan.out")
	         }
          }
        }
      }
    }
  }
  post {
     always{
	addShortText(params.version)
	addShortText(params.environment)
	cleanWs()
     }
  }
}
