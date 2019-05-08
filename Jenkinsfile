#!/usr/bin/env groovy
import static groovy.json.JsonOutput.toJson

/*
 * This build and run docker image to perform a source code escrow
 */

properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '3']]])

def time = System.currentTimeMillis()

node {
    timestamps {
        ansiColor('xterm') {
            stage('Checkout') {
                checkout scm
            }

            stage("Build 🐳 escrow image") {
                sh """
                    # use no-cache to ensure we are always able to build a fresh image from scratch
                    docker build --no-cache -t escrow$time .
                """
            }
        }
    }
}

node {
    def volume = "buildEscrow" + time
    def onlineContainer = "onlineContainer" + time
    def offlineContainer = "offlineContainer" + time
    sh " docker volume create  $volume "
    try {
        stage("Escrow online") {
            try {
                sh "docker run -v $volume:/home/deposit/build --name $onlineContainer -m 4GB escrow$time"
                if (shouldArchiveOnlineResult) {
                    archiveOnlineResult('build.tar.gz',onlineContainer)
                }
            } finally {
                archiveLogsAndDeleteContainer('/home/escrow', 'build_online.log', onlineContainer)
            }
        }

        // --net none --add-host=escrow:10.0.0.1 --hostname=escrow
        // => We must ensure that the container doesn't have internet access, but we must provide a hostname to avoid some issues
        stage("Escrow offline") {
            try {
                sh "docker run -v $volume:/home/deposit/build/offline --name $offlineContainer -m 4GB --net none --add-host=escrow:10.0.0.1 --hostname=escrow escrow$time ./build/offline/build.sh --offline "
            } finally {
                archiveLogsAndDeleteContainer('/home/deposit/build/offline', 'build_offline.log', offlineContainer)
            }
        }
    } finally {
        sh "docker volume rm $volume"
    }
}

def archiveLogsAndDeleteContainer(String path, String logFile, String container) {
    try {
        sh "docker cp $container:$path/$logFile ."
        archiveArtifacts logFile
    } finally {
        sh "docker rm -f $container"
    }
}

def archiveOnlineResult(String archiveFile, String container) {
    sh "docker cp $container:/home/deposit/$archiveFile  ."
    archiveArtifacts archiveFile
}
