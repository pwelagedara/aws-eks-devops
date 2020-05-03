#!/bin/sh

CLUSTER_NAME=${1:-rnd-eks-cluster}

# Destroy cluster
eksctl delete cluster --name ${CLUSTER_NAME}

