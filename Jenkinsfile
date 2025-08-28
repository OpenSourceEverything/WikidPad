pipeline {
  agent { docker { image 'python:3.10-bookworm' } }
  stages {
    stage('CI') {
      steps {
        sh 'make ci'
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
    }
  }
}
