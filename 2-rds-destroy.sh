#!/bin/sh

DB_NAME=rds-cluster
DB_SUBNET_GROUP_NAME=rds-subnet-group

export KUBECONFIG=${PWD}/kubeconfig.yaml

# Destroy the service
kubectl delete -f ./dist/rds-service.yaml

# Get the Security Group and delete the ingress rule
OUT=$(aws rds describe-db-clusters --db-cluster-identifier $DB_NAME)

RDS_VPC_SECURITY_GROUP_ID=$(echo $OUT | jq -r '.DBClusters[0].VpcSecurityGroups[0].VpcSecurityGroupId')

aws ec2 revoke-security-group-ingress \
    --group-id ${RDS_VPC_SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 3306 \
    --cidr 192.168.0.0/16

aws rds delete-db-cluster \
    --db-cluster-identifier $DB_NAME \
    --skip-final-snapshot

# Wait for 15 mins
sleep 900

# Delete Subnet Group
aws rds delete-db-subnet-group \
    --db-subnet-group-name  "${DB_SUBNET_GROUP_NAME}"

# TODO: 22/02/20 Be more precise when selecting the Subnet to delete
OUT=$(aws ec2 describe-subnets --filters Name="cidr-block",Values="192.168.225.0/24,192.168.226.0/24,192.168.227.0/24")

SUBNET_A=$(echo $OUT | jq -r '.Subnets[0].SubnetId')
SUBNET_B=$(echo $OUT | jq -r '.Subnets[1].SubnetId')
SUBNET_C=$(echo $OUT | jq -r '.Subnets[2].SubnetId')

# Delete Subnets
aws ec2 delete-subnet --subnet-id $SUBNET_A
aws ec2 delete-subnet --subnet-id $SUBNET_B
aws ec2 delete-subnet --subnet-id $SUBNET_C



