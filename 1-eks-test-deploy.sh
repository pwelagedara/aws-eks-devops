#!/bin/sh

SUB_DOMAIN=${1:-hello-kubernetes}

HOSTED_ZONE=${2:-rnd.pubudu.info}

CERTIFICATE_ARN=${3:-"arn:aws:acm:ap-southeast-1:783338451369:certificate/1213bc7e-2507-4b54-86c0-b993e2faced6"}

HOST="${SUB_DOMAIN}.${HOSTED_ZONE}"

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Generate the files
cat ./hello-deployment.yaml \
    > ./dist/hello-deployment.yaml

cat ./hello-service.yaml \
    > ./dist/hello-service.yaml

# Used "%" as delimiter to avoid errors you come across due to having "/" in CERTIFICATE_ARN
cat ./hello-ingress.yaml \
    | sed "s%CERTIFICATE_ARN%${CERTIFICATE_ARN}%g" \
    | sed "s/HOST/${HOST}/g" \
    > ./dist/hello-ingress.yaml

sleep 5 

# Deploy the app
kubectl apply -f ./dist/hello-deployment.yaml
kubectl apply -f ./dist/hello-service.yaml
kubectl apply -f ./dist/hello-ingress.yaml
