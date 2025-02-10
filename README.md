# Description of the process to configure infra
## Step 1: Set-up plugin

## Install Plugins in Jenkins

1. **Eclipse Temurin Installer**:
   - This plugin enables Jenkins to automatically install and configure the Eclipse Temurin JDK (formerly known as AdoptOpenJDK).
   - To install, go to Jenkins dashboard -> Manage Jenkins -> Manage Plugins -> Available tab.
   - Search for "Eclipse Temurin Installer" and select it.
   - Click on the "Install without restart" button.

2. **Pipeline Maven Integration**:
   - This plugin provides Maven support for Jenkins Pipeline.
   - It allows you to use Maven commands directly within your Jenkins Pipeline scripts.
   - To install, follow the same steps as above, but search for "Pipeline Maven Integration" instead.

3. **Config File Provider**:
   - This plugin allows you to define configuration files (e.g., properties, XML, JSON) centrally in Jenkins.
   - These configurations can then be referenced and used by your Jenkins jobs.
   - Install it using the same procedure as mentioned earlier.

4. **SonarQube Scanner**:
   - SonarQube is a code quality and security analysis tool.
   - This plugin integrates Jenkins with SonarQube by providing a scanner that analyzes code during builds.
   - You can install it from the Jenkins plugin manager as described above.

5. **Kubernetes CLI**:
   - This plugin allows Jenkins to interact with Kubernetes clusters using the Kubernetes command-line tool (`kubectl`).
   - It's useful for tasks like deploying applications to Kubernetes from Jenkins jobs.
   - Install it through the plugin manager.

6. **Kubernetes**:
   - This plugin integrates Jenkins with Kubernetes by allowing Jenkins agents to run as pods within a Kubernetes cluster.
   - It provides dynamic scaling and resource optimization capabilities for Jenkins builds.
   - Install it from the Jenkins plugin manager.

7. **Docker**:
   - This plugin allows Jenkins to interact with Docker, enabling Docker builds and integration with Docker registries.
   - You can use it to build Docker images, run Docker containers, and push/pull images from Docker registries.
   - Install it from the plugin manager.

8. **Docker Pipeline Step**:
   - This plugin extends Jenkins Pipeline with steps to build, publish, and run Docker containers as part of your Pipeline scripts.
   - It provides a convenient way to manage Docker containers directly from Jenkins Pipelines.
   - Install it through the plugin manager like the others.

After installing these plugins, you may need to configure them according to your specific environment and requirements. This typically involves setting up credentials, configuring paths, and specifying options in Jenkins global configuration or individual job configurations. Each plugin usually comes with its own set of documentation to guide you through the configuration process.

![alt text](image.png)


# Configure Sonar tool: 
* Generate the Sonar Token from the sonar server : Administration -> security -> user -> token
* create the sonar token in jenkins
### configure sonar server in jenkins using token created above
1. Jenkins -> MAnage Jenkins -> System
2. then configure the sonar server section

## For Quality Gate: 
- configure the webhook in sonar : Administration -> Configuration -> Webhook -> then click on create :
    - name : type the name
    - url : http://34.212.42.72:8080/sonarqube-webhook/

## Build source code and generate jar file: 


## Pipeline 

```groovy


pipeline{
    agent any 
    tools {
        maven 'M2_HOME'
    }
    environment {
      AWS_REGION = 'us-east-1'
      SCANNER_HOME= tool 'sonar'
      ARTIFACTORY_URL=  'http://54.90.160.188:8081/artifactory'
      REPO = 'geolocation'
      APP_NAME = 'geoapp'
      APP_OWNER = 'cloud_team'
      DOCKER_REPO_NAME = "${APP_NAME}"
      REPO_URL     = 'public.ecr.aws/g0j7o9l5'
      DOCKER_REPO = "${REPO_URL}/${DOCKER_REPO_NAME}"
      BRANCH_NAME= 'main'
      GIT_CRED = 'GITHUB_CRED'
      KUBERNETES_CRED = 'KUBERNETES_CRED'
      KUBERNETES_URL = 'https://104.237.133.213:6443'
      SONAQUBE_CRED = 'sonarqube_ID'
      SONAQUBE_INSTALLATION = 'Sonarqube'
      JFROG_CRED = 'j_frog-cred'
      PROJECT_URL = 'https://github.com/kserge2001/cicd-code.git'
      ARTIFACTPATH = 'target/*.jar'
      ARTIFACTTARGETPATH = "release_${BUILD_ID}.jar"
      HELMARTIFACTPATH = "geoapp-${BUILD_ID}.tgz"
      HELMARTIFACTTARGET = "heml/geoapp-${BUILD_ID}.tgz"

    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: "${BRANCH_NAME}", credentialsId: "${GIT_CRED}", \
                url: "${PROJECT_URL}"
            }
        }
       
        // this stage is for test
        stage('Unit Test'){
            steps{
                sh 'mvn clean'
                sh 'mvn compile '
                sh 'mvn test'
            }
        }
        
        stage('Sonarqube Scan'){
            steps{
                withSonarQubeEnv(credentialsId: "${SONAQUBE_CRED}", \
                installationName: "${SONAQUBE_INSTALLATION}" ) {
              sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=${APP_NAME} -Dsonar.projectKey=${APP_NAME} \
                   -Dsonar.java.binaries=. '''
}
            }
        }
        stage('Quality Gate Check'){
            steps{
              script{
                 waitForQualityGate abortPipeline: false, credentialsId: "${SONAQUBE_CRED}" 
              }
            }
        }
        
        stage('Trivy Scan'){
            steps{
                 sh "trivy fs --format table -o maven_dependency.html ."
            }
        }
       
     
        stage('Code Package'){
            steps{
                sh 'mvn package'
            }
        }
      
        stage('Upload Jar to Jfrog'){
            steps{
                withCredentials([usernamePassword(credentialsId: "${JFROG_CRED}", \
                 usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASSWORD')]) {
                    script {
                        // Define the artifact path and target location
                        //def artifactPath = 'target/*.jar'
                        //def targetPath = "release_${BUILD_ID}.jar"

                        // Upload the artifact using curl
                        sh """
                            curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} \
                                 -T ${ARTIFACTPATH} \
                                 ${ARTIFACTORY_URL}/${REPO}/${ARTIFACTTARGETPATH}
                        """
            }
        }
    }

}

    stage('Docker image Build'){
        steps{
            script{
           sh "docker build --no-cache -t ${DOCKER_REPO}:latest ."
           sh "docker build --no-cache -t ${DOCKER_REPO}:${BUILD_ID} ."
            }
           
        }
    }
  
    stage('Scan Docker Image'){
        steps{
          sh """trivy image --format table -o docker_image_report.html ${DOCKER_REPO}:${BUILD_ID}"""
  
        }
    }
  
    stage('Push Image To Registry'){
        steps{
          script{
        //def ecr_passwrd=sh(script: "aws ecr-public get-login-password --region 'us-east-1'")
         //sh "docker login --username AWS --password ${ecr_passwrd} public.ecr.aws/g0j7o9l5"   
        sh "aws ecr-public get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REPO_URL}"
        sh "docker push ${DOCKER_REPO}:latest "
        sh "docker push ${DOCKER_REPO}:${BUILD_ID} "
        }
    }
    }

    stage('Chart Version Update'){
        steps{
         sh "python3 setup_scripts/chartUpdate.py ${BUILD_ID}" 
           
        }
    }
    stage('Package Helm'){
        steps{
            sh 'helm package geoapp'
        }
    }

    stage('Upload helm package to Jfrog'){
            steps{
                 withCredentials([usernamePassword(credentialsId: "${JFROG_CRED}", \
                 usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASSWORD')]) {
                    script {
                        // Define the artifact path and target location
                        //def artifactPath = 'geo-app-${BUILD_ID}.tgz'
                        //def targetPath = "heml/geo-app-${BUILD_ID}.tgz"

                        // Upload the artifact using curl
                        sh """
                            curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} \
                                 -T ${HELMARTIFACTPATH} \
                                 ${ARTIFACTORY_URL}/${REPO}/${HELMARTIFACTTARGET}
                        """
            }
        }
    }
    

}

stage('Deploy helm to k8s'){
    steps{
        kubeconfig(credentialsId: "${KUBERNETES_CRED}" ,caCertificate: '', serverUrl: "${KUBERNETES_URL}") {
    
   // sh 'helm rollback geo -n dev'
   // sh 'sleep 60'
   sh 'kubectl delete secret -l owner=helm,name=geo -n dev'
    sh 'helm upgrade --install geo geoapp -n dev'
    

    }
  }
}
 
    }
    
    post {
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'SUCCESS'
            def bannerColor = pipelineStatus == 'SUCCESS' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3>Please see attached report </h3>
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus}",
                body: body,
                to: 'unixclassd1@gmail.com',
                from: 'unixclassd1@gmail.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'maven_dependency.html, docker_image_report.html'
            )
        }
        
    }
    failure {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'SUCCESS'
            def bannerColor = pipelineStatus == 'SUCCESS' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus}",
                body: body,
                to: 'unixclassd1@gmail.com',
                from: 'unixclassd1@gmail.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'maven_dependency.html, docker_image_report.html'
            )
        }
     }
    
    } 
   
}
```
# utrains terraform aws AMI 
This code allows to create in aws a jenkins server so several plugins, java maven, git and docker are already installed. we use in this case, an AMI image.

## Nexus AMI Login :
- user : admin
- pwd : devops

