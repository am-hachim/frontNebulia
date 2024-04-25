FROM debian:bookworm

# set the github runner version
# ARG RUNNER_VERSION="2.316.0 Latest"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && apt-get install ca-certificates curl gnupg -y && useradd -m github 

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip libicu-dev

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/github && mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-2.316.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.316.0.tar.gz

# install some additional dependencies
RUN chown -R github ~github && /home/github/actions-runner/bin/installdependencies.sh

RUN install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg && chmod a+r /etc/apt/keyrings/docker.gpg && echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh && usermod -aG docker github

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER github

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]