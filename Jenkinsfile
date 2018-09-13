def uploadSpec = """{
  "files": [
    {
      "pattern": "/opt/dataduck/dataduck-99.0.2.gem",
      "target": "gems-local/gems/"
    }
  ]
}"""

pipeline {
  agent {
    label "hellofax && develop"
  }
  stages{
    stage("Dataduck Builder") {
      steps {
        sh "sudo mkdir -p /opt/dataduck"
        sh "sudo cp -rfp ${WORKSPACE}/. /opt/dataduck"
        sh "sudo chown -R ubuntu:root /opt/dataduck"
        sh "cd /opt/dataduck && ./jenkins/build.sh"
        sh "sudo cp /opt/dataduck/dataduck-99.0.2.gem ${WORKSPACE}"
        archiveArtifacts 'dataduck-99.0.2.gem'
      }
    }
  }
  post {
    success {
      script {
        // Obtain an Artifactory server instance, defined in Jenkins --> Manage:
        def server = Artifactory.server 'artifactory'

        // Upload files to Artifactory:
        def buildInfo = server.upload spec: uploadSpec

        // Publish the merged build-info to Artifactory
        server.upload spec: uploadSpec, buildInfo: buildInfo
        server.publishBuildInfo buildInfo
        server.upload(uploadSpec)
      }
    }
  }
}