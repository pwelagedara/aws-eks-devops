#!/bin/sh

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Destroy the client
kubectl delete pod mysql-client>/dev/null