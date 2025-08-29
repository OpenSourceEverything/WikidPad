pipeline {
  agent none
  environment {
    USE_SYSTEM_WX = '1'
  }
  stages {
    stage('Linux Matrix') {
      parallel {
        stage('ubuntu-22.04') {
          agent { docker { image 'ubuntu:22.04' } }
          steps {
            sh 'bash scripts/os_deps.sh && make ci'
            sh 'mkdir -p ci-collect && mv artifacts ci-collect/artifacts-ubuntu-22.04 || true'
          }
        }
        stage('ubuntu-24.04') {
          agent { docker { image 'ubuntu:24.04' } }
          steps {
            sh 'bash scripts/os_deps.sh && make ci'
            sh 'mkdir -p ci-collect && mv artifacts ci-collect/artifacts-ubuntu-24.04 || true'
          }
        }
        stage('debian-11') {
          agent { docker { image 'debian:11' } }
          steps {
            sh 'bash scripts/os_deps.sh && make ci'
            sh 'mkdir -p ci-collect && mv artifacts ci-collect/artifacts-debian-11 || true'
          }
        }
        stage('debian-12') {
          agent { docker { image 'debian:12' } }
          steps {
            sh 'bash scripts/os_deps.sh && make ci'
            sh 'mkdir -p ci-collect && mv artifacts ci-collect/artifacts-debian-12 || true'
          }
        }
        stage('fedora-40') {
          agent { docker { image 'fedora:40' } }
          steps {
            sh 'bash scripts/os_deps.sh && make ci'
            sh 'mkdir -p ci-collect && mv artifacts ci-collect/artifacts-fedora-40 || true'
          }
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'ci-collect/**', allowEmptyArchive: true
    }
  }
}
