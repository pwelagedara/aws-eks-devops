#!/bin/sh

RELEASE_NAME=${1:-jenkins}

export KUBECONFIG=${PWD}/kubeconfig.yaml

helm delete $RELEASE_NAME

