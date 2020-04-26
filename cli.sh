#!/usr/bin/env bash

# Login to ECR

exec $(aws ecr get-login --no-include-email --profile AdminFrench)

# Retrieve the ECR metabase repo URI
REPO_URI=$(aws ecr describe-repositories --profile AdminFrench | jq -r '.repositories | .[] | .repositoryUri')

# Tag the local image against it, assumes TAG= latest
docker tag $(docker images metabase/metabase -q) $REPO_URI

# Push the image
docker push $REPO_URI
