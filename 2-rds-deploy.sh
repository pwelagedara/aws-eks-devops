#!/bin/sh

DB_NAME=rds-cluster
DB_SUBNET_GROUP_NAME=rds-subnet-group
DB_CAPACITY_MIN=1
DB_CAPACITY_MAX=4
DB_USERNAME=${1:-username}
DB_PASSWORD=${2:-tpNrNbpWy2srkMWb}

REGION=ap-southeast-1

export KUBECONFIG=${PWD}/kubeconfig.yaml

VPC_ID=$(aws ec2 describe-instances --filters Name="tag:alpha.eksctl.io/nodegroup-name",Values="ng-on-demand" \
    | jq -r '.Reservations[0].Instances[0].VpcId')

# Create 3 Subnets
SUBNET_A=$(aws ec2 create-subnet --availability-zone "${REGION}a" \
    --vpc-id ${VPC_ID} --cidr-block 192.168.225.0/24 \
    | jq -r '.Subnet.SubnetId')

SUBNET_B=$(aws ec2 create-subnet --availability-zone "${REGION}b" \
    --vpc-id ${VPC_ID} --cidr-block 192.168.226.0/24 \
    | jq -r '.Subnet.SubnetId')

SUBNET_C=$(aws ec2 create-subnet --availability-zone "${REGION}c" \
    --vpc-id ${VPC_ID} --cidr-block 192.168.227.0/24 \
    | jq -r '.Subnet.SubnetId')

# Create a DB Subnet Group
aws rds create-db-subnet-group \
    --db-subnet-group-name  "${DB_SUBNET_GROUP_NAME}" \
    --db-subnet-group-description "RDS DB Subnet Group" \
    --subnet-ids "${SUBNET_A}" "${SUBNET_B}" "${SUBNET_C}" \
    | jq '{DBSubnetGroupName:.DBSubnetGroup.DBSubnetGroupName,VpcId:.DBSubnetGroup.VpcId,Subnets:.DBSubnetGroup.Subnets[].SubnetIdentifier}'

# Create the Cluster
OUT=$(aws rds create-db-cluster \
    --db-cluster-identifier $DB_NAME \
    --engine aurora --engine-version 5.6.10a \
    --engine-mode serverless \
    --scaling-configuration MinCapacity=$DB_CAPACITY_MIN,MaxCapacity=$DB_CAPACITY_MAX,SecondsUntilAutoPause=1000,AutoPause=true \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --master-username $DB_USERNAME \
    --master-user-password $DB_PASSWORD)

RDS_VPC_SECURITY_GROUP_ID=$(echo $OUT | jq -r '.DBCluster.VpcSecurityGroups[0].VpcSecurityGroupId')
ENDPOINT=$(echo $OUT | jq -r '.DBCluster.Endpoint')

# Update the Security Group to allow all inbound traffic from the VPC on port 3306
aws ec2 authorize-security-group-ingress \
    --group-id ${RDS_VPC_SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 3306 \
    --cidr 192.168.0.0/16

# Generate the files
cat ./rds-service.yaml \
    | sed "s/ENDPOINT/${ENDPOINT}/g" \
    > ./dist/rds-service.yaml

sleep 5

# Create the service
kubectl apply -f ./dist/rds-service.yaml