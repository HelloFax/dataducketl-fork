def uploadSpec = """{
  "files": [
    {
      "pattern": "/opt/dataduck/dataduck-*.gem",
      "target": "gems-local/gems/"
    }
  ]
}"""

pipeline {
  environment {
    BUILD_VERSION = "99.0.4"
  }
  agent {
    node {
      label 'cibase'
      customWorkspace '/opt/dataduck'
    }
  }
  stages{
    stage("Dataduck Builder") {
      when{
        branch 'master'
      }
      steps {
        sh "./jenkins/build.sh ${BUILD_VERSION}"
        archiveArtifacts "dataduck-${BUILD_VERSION}.gem"
      }
    }
    stage("Push to artifactory") {
      when{
        branch 'master'
      }
      steps {
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
}
