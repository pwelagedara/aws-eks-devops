#!/bin/sh

JENKINS_ADMIN_USER=${1:-jenkins}
NAMESPACE=${2:-default}
RELEASE_NAME=${3:-jenkins}

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Install Jenkins
helm install \
    $RELEASE_NAME \
    --namespace $NAMESPACE \
    --set master.adminUser=$JENKINS_ADMIN_USER \
    --values ./jenkins-values.yaml \
    stable/jenkins

# This is the fix for the below error
# User "system:serviceaccount:default:default" cannot list resource "pods" in -
# - API group "" in the namespace "kube-system"
# TODO: 23/02/20 Check if this error changes from namespace to namespace
kubectl create clusterrolebinding \
    --user system:serviceaccount:default:default default-sa-admin \
    --clusterrole cluster-admin

