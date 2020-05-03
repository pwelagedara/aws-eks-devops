#!/bin/sh

DB_USERNAME=${1:-username}
DB_PASSWORD=${2:-tpNrNbpWy2srkMWb}
DB_SERVICE_NAME=rds-service

export KUBECONFIG=${PWD}/kubeconfig.yaml

kubectl run -it --rm \
    --image=mysql:5.6 \
    --restart=Never mysql-client \
    -- mysql -h $DB_SERVICE_NAME -u $DB_USERNAME -p$DB_PASSWORD