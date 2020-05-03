# aws-eks-devops

## 1. How to get the infrastructure running

Please exercise caution when running teardown scripts. Consider cleaning up manually as it is much safer.

### 1.1. Prerequisites

- A Key Pair in your region
- A Hosted Zone in Route 53( e.g. example.com)
- An ACM Public Certificate for example.com and *.example.com
- AWS Cli
- eksctl
- kubectl
- helm 3

### 1.2. Deployment

#### 1.2.1. Modify the variables in `*-deploy.sh` files. 

Variable Name | Description | Example
--- | --- | ---
HOSTED_ZONE | Hosted Zone in Route 53 | example.com
CLUSTER_NAME | Give any name to your cluster | my-eks-cluster
KEY_PAIR | The Key Pair to SSH into EC2 Instances in your region | RnDEKSKeyPair
REGION | Region | ap-southeast-1
ON_DEMAND_DESIRED_CAPACITY | Desired number of On Demand instances in the cluster | 2
ON_DEMAND_INSTANCE_TYPE | On Demand instance type | m5.large
SPOT_MIN | Minimum Spot instance limit | 2
SPOT_MAX | Maximum Spot instance limit | 3
SPOT_INSTANCE_TYPE_1 | Spot instance type 1. You need at least 2 Spot instance types for a Spot Node Group| m5.large
SPOT_INSTANCE_TYPE_2 | Spot instance type 2. You need at least 2 Spot instance types for a Spot Node Group | m5.xlarge
CLUSTER_AUTOSCALER_VERSION | Cluster Autoscaler Version | Get it from [here](https://github.com/kubernetes/autoscaler/releases). It should match the Kubernetes version in EKS
SUB_DOMAIN | A Sub Domain in your hosted zone to test your app | test
CERTIFICATE_ARN | Get the arn from ACM | arn:aws:acm:ap-southeast-1:783338451369:certificate/1213bc7e-2507-4b54-86c0-b993e2faced6
DB_NAME | The Database name in RDS | my-rds-cluster
DB_SUBNET_GROUP_NAME | Subnet Group Name for Database Deployment | 1
DB_CAPACITY_MIN | Minimum Database Capacity( for Serverless) | 4
DB_CAPACITY_MAX | Minimum Database Capacity( for Serverless) | 3
DB_USERNAME | Database Username | root
DB_PASSWORD | Database Password | password
DB_SERVICE_NAME | Service Name to use inside the cluster | db-service

#### 1.2.2. Run the Scripts from 0 to 3

You might want to leave sometime between running `2-rds-deploy.sh` and `3-rds-test-deploy.sh` as the Database creation takes a few minutes.

After Jenkins deployment add AWS Credentials with ID `86c8f5ec-1ce1-4e94-80c2-18e23bbd724a`. Refer to [this](https://foxutech.com/setup-jenkins-with-amazon-elastic-container-registry/) for more details on how to add this.

To test if everything works add this repo to Jenkins.

```
./0-eks-deploy.sh
./1-eks-test-deploy.sh
./2-rds-deploy.sh

# Wait for some time before executing the next file
./3-rds-test-deploy.sh

./4-jenkins-deploy.sh
```

## 2. Database Scripts

TODO: 23/02/20 Update this

## 3. Deploying the Application

TODO: 23/02/20 Update this

## 4. CI and CD Pipeline Setup

TODO: 23/02/20 Update this

## 5. References

- https://medium.com/@Joachim8675309/alb-ingress-with-amazon-eks-3d84cf822c85
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.create.html
- https://dev.to/bensooraj/accessing-amazon-rds-from-aws-eks-2pc3
- https://ec2spotworkshops.com/using_ec2_spot_instances_with_eks/spotworkers/workers_eksctl.html
- https://ec2spotworkshops.com/using_ec2_spot_instances_with_eks/spotworkers/deployhandler.html
- https://ec2spotworkshops.com/using_ec2_spot_instances_with_eks/scaling/deploy_ca.html
- https://plugins.jenkins.io/amazon-ecr/
- https://foxutech.com/setup-jenkins-with-amazon-elastic-container-registry/

## 6. Good Reads

- https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/
- https://medium.com/@Joachim8675309/adding-ingress-with-amazon-eks-6c4379803b2
