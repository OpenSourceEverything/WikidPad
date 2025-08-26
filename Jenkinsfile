pipeline {
  agent { docker { image 'python:3.10-bookworm' } }
  stages {
    stage('Install') {
      steps {
        sh 'bash scripts/ci_install.sh'
      }
    }
    stage('Test') {
      steps {
        sh 'bash scripts/ci_test_gui.sh'
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
    }
  }
}
