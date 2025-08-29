pipeline {
  agent { label 'docker' }
  environment {
    USE_SYSTEM_WX = '1'
  }
  stages {
    stage('Matrix via docker_matrix.sh') {
      steps {
        sh 'bash scripts/docker_matrix.sh'
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'artifacts-matrix/**', allowEmptyArchive: true
    }
  }
}
