node ('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            checkout scm
            GIT_COMMIT_HASH = sh(
                script: 'git rev-parse HEAD',
                returnStdout: true
            ).trim()
        }

        def restoreSidecar
        def backupSidecar
        def nginx
        stage('Build') {
            dir('joomla') {
                restoreSidecar = docker.build("scos/joomla-restore:${GIT_COMMIT_HASH}")
            }
            dir('cron-docker') {
                backupSidecar = docker.build("scos/joomla-cron:${GIT_COMMIT_HASH}")
            }
            dir('nginx') {
                nginx = docker.build("scos/joomla-nginx:${GIT_COMMIT_HASH}")
            }
        }

        stage('Test') {
            //TODO stand them up, wait for the restore to finish then healthcheck??
        }

        stage('Publish') {
            docker.withRegistry("https://199837183662.dkr.ecr.us-east-2.amazonaws.com", "ecr:us-east-2:aws_jenkins_user") {
                restoreSidecar.push()
                backupSidecar.push()
                nginx.push()
            }
        }
        
        stage('Deploy to Dev') {
            //TODO
        }
    }
}