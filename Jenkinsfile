#!/usr/bin/groovy

podTemplate(label: 'jenkins-pipeline', containers: [
    containerTemplate(name: 'docker', image: 'docker:19.03.6', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:v3.1.0', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.17.3', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){

    node ('jenkins-pipeline') {

        checkout scm

        def inputFile = readFile('Hintfile.json')
        def config = new groovy.json.JsonSlurperClassic().parseText(inputFile)

        println "${config}"
        println "${config.namespace}"
        println "${config.app.name}"

        sh "git remote -v"
        sh "git branch"

        stage ('helm test') {
            container('helm') {
                    sh "helm list --all-namespaces"
            }
        }

        stage ('docker test') {
            container('docker') {
                
                sh "docker ps"
                sh "docker pull paulbouwer/hello-kubernetes:1.7"
                sh "docker tag paulbouwer/hello-kubernetes:1.7 783338451369.dkr.ecr.ap-southeast-1.amazonaws.com/hello-kubernetes:latest"

                docker.withRegistry('https://783338451369.dkr.ecr.ap-southeast-1.amazonaws.com', "ecr:ap-southeast-1:${config.awsCredentialsId}") {
                    sh "docker push 783338451369.dkr.ecr.ap-southeast-1.amazonaws.com/hello-kubernetes:latest"
                }
            }
        }

        stage ('kubectl test') {
            container('kubectl') {
                sh "kubectl get pods"
            }
        }

    }
}