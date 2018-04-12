
pipeline {
  agent {
    label "xenial"
  }
  stages{
    stage("Dataduck Builder") {
      steps {
        sh "apt-get install ruby-rspec-core"
        sh "bundle install"
        sh "bundle exec rspec"
        sh "gem build dataduck.gemspec"
        archiveArtifacts 'dataduck-0.7.0.gem'
      }
    }
  }
}