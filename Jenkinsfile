def uploadSpec = """{
  "files": [
    {
      "pattern": "dataduck-*.gem",
      "target": "gems-local/gems/"
    }
  ]
}"""

pipeline {
  environment {
    BUILD_VERSION = "99.1.4"
  }
  agent {
    node {
      label 'focal && etl && v1'
    }
  }
  stages{
    stage("Dataduck Builder") {
      steps {
        script {
          def build_ok = sh(returnStatus: true, script: "./build.sh ${BUILD_VERSION} ${WORKSPACE}")
          echo "build returned $build_ok"
          if (build_ok == 0) {
            archiveArtifacts "dataduck-${BUILD_VERSION}.gem"
          } else {
            currentBuild.result = 'FAILURE'
          }
        }
      }
    }
    stage("Push to artifactory") {
//      when{
//        branch 'master'
//      }
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
