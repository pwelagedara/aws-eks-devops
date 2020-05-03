#!/bin/sh

HOSTED_ZONE=${1:-rnd.pubudu.info}

CLUSTER_NAME=${2:-rnd-eks-cluster}

KEY_PAIR=${3:-RnDEKSKeyPair}

REGION=ap-southeast-1

ON_DEMAND_DESIRED_CAPACITY=1
ON_DEMAND_INSTANCE_TYPE=m5.large

SPOT_MIN=1
SPOT_MAX=5
SPOT_INSTANCE_TYPE_1=m5.large
SPOT_INSTANCE_TYPE_2=t2.medium

CLUSTER_AUTOSCALER_VERSION=v1.14.7

# Generate the files
cat ./eks.yaml \
    | sed "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    | sed "s/REGION/${REGION}/g" \
    | sed "s/KEY_PAIR/${KEY_PAIR}/g" \
    | sed "s/ON_DEMAND_DESIRED_CAPACITY/${ON_DEMAND_DESIRED_CAPACITY}/g" \
    | sed "s/ON_DEMAND_INSTANCE_TYPE/${ON_DEMAND_INSTANCE_TYPE}/g" \
    | sed "s/SPOT_MIN/${SPOT_MIN}/g" \
    | sed "s/SPOT_MAX/${SPOT_MAX}/g" \
    | sed "s/SPOT_INSTANCE_TYPE_1/${SPOT_INSTANCE_TYPE_1}/g" \
    | sed "s/SPOT_INSTANCE_TYPE_2/${SPOT_INSTANCE_TYPE_2}/g" \
    > ./dist/eks.yaml

cat ./external-dns-values.yaml \
    | sed "s/HOSTED_ZONE/${HOSTED_ZONE}/g" \
    > ./dist/external-dns-values.yaml

cat ./cluster-autoscaler-autodiscover.yaml \
    | sed "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    | sed "s/CLUSTER_AUTOSCALER_VERSION/${CLUSTER_AUTOSCALER_VERSION}/g" \
    > ./dist/cluster-autoscaler-autodiscover.yaml

sleep 5

# Create EKS Cluster
eksctl create cluster -f ./dist/eks.yaml --kubeconfig kubeconfig.yaml

sleep 5

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Initialize Helm 3
helm repo add incubator \
    http://storage.googleapis.com/kubernetes-charts-incubator

helm repo add stable \
    https://kubernetes-charts.storage.googleapis.com/

helm repo add eks \
    https://aws.github.io/eks-charts

helm repo update

# Install Spot Interrupt Handler
helm install \
    --generate-name \
    --namespace kube-system \
    --set nodeSelector.lifecycle=Ec2Spot \
    eks/aws-node-termination-handler

# Configure ALB Ingress
helm install \
    incubator/aws-alb-ingress-controller \
    --namespace kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set autoDiscoverAwsRegion=true \
    --set autoDiscoverAwsVpcID=true \
    --generate-name

helm install \
    stable/external-dns \
    --namespace kube-system \
    --generate-name \
    --values ./dist/external-dns-values.yaml

# Check if everything is installed
helm list --all-namespaces

# Cluster Autoscaler
kubectl apply -f ./dist/cluster-autoscaler-autodiscover.yaml

kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
