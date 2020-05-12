#!/usr/bin/env bash

# Login to ECR

exec $(aws ecr get-login --no-include-email --profile Admin)
# Retrieve the ECR metabase repo URI
REPO_URI=$(aws ecr describe-repositories --profile Admin | jq -r '.repositories | .[] | .repositoryUri')
# Retrieve the image from DockerHub
docker pull metabase/metabase
# Tag the local image against it, assumes TAG= latest
docker tag $(docker images metabase/metabase -q) $REPO_URI
# Push the image
docker push $REPO_URI
