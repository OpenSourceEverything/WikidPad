// Jenkins CI: run the same Docker-based Linux matrix used by GitHub/GitLab
// - Calls scripts/docker_matrix.sh which reads scripts/distros.list
// - Archives artifacts-matrix/** for debugging
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
