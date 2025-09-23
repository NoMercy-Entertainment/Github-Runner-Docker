# base image
FROM ubuntu:24.04

#input GitHub runner version argument
ARG RUNNER_VERSION=2.304.0
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Stoney_Eagle"
LABEL Email="stoney@nomercy.tv"
LABEL GitHub="https://github.com/StoneyEagle"
LABEL BaseImage="ubuntu:24.04"
LABEL RunnerVersion=${RUNNER_VERSION}

WORKDIR /root

RUN apt-get update -y && apt-get upgrade -y

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git jq build-essential libssl-dev libffi-dev \
    python3 python3-venv python3-dev python3-pip ca-certificates gnupg sudo

RUN apt-get install curl && curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# cd into the user directory, download and unzip the github actions runner
RUN mkdir -p actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chmod +x actions-runner/bin/installdependencies.sh && actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh /root/start.sh

# make the script executable
RUN chmod +x /root/start.sh

# set the entrypoint to the start.sh script
ENTRYPOINT ["/root/start.sh"]