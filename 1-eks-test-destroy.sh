#!/bin/sh

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Delete the records added to the Hosted Zone. They will not affect much though

# Destroy the app
kubectl delete -f ./dist/hello-deployment.yaml
kubectl delete -f ./dist/hello-service.yaml
kubectl delete -f ./dist/hello-ingress.yaml
