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
        sh "sudo cp /opt/dataduck/dataduck-0.7.0.gem ${WORKSPACE}"
        archiveArtifacts 'dataduck-0.7.0.gem'
      }
    }
  }
}