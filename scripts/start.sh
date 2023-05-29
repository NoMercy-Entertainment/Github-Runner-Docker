#!/bin/bash

echo "Configuring runner..."

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="runner-$RUNNER_SUFFIX"

cd /home/docker/actions-runner

reg_url=https://api.github.com/orgs/$GITHUB_ORG/actions/runners/registration-token

AUTH_RESPONSE=$(curl -sS -X POST -H "Authorization: Bearer $GH_TOKEN" $reg_url)

RESPONE_MESSAGE=$(echo $AUTH_RESPONSE | jq .message --raw-output)

if [ "$RESPONE_MESSAGE" == "Bad credentials" ]; then
    echo "Error: $RESPONE_MESSAGE"
    exit 1
fi

REG_TOKEN=$(echo $AUTH_RESPONSE | jq -r .token)

if [ "$REG_TOKEN" == "null" ]; then
    echo "Error: No registration token found"
    exit 1
fi

export ENV RUNNER_ALLOW_RUNASROOT=1

./config.sh \
  --replace \
  --unattended \
  --token $REG_TOKEN \
  --url https://github.com/$GITHUB_ORG \
  --labels ${RUNNER_LABELS:-unlabeled} \
  --name $RUNNER_NAME

  
remove () {
  local rem_url=https://api.github.com/orgs/$GITHUB_ORG/actions/runners/remove-token
  local rem_token=$(curl -sS -X POST -H "Authorization: Bearer $GITHUB_TOKEN" $rem_url | jq -r .token)
  ./config.sh remove --token $rem_token
}

trap remove EXIT

./bin/runsvc.sh
