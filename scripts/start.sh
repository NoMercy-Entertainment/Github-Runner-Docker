#!/bin/bash

echo "Configuring runner..."

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="runner-$RUNNER_SUFFIX"

cd /root/actions-runner

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
  ./config.sh remove --token $REG_TOKEN
}

trap remove EXIT

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./bin/runsvc.sh