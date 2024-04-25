#!/bin/bash

#ORGANIZATION=$ORGANIZATION
#ACCESS_TOKEN=$ACCESS_TOKEN

#REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
cd /home/github/actions-runner

./config.cmd --url https://github.com/am-hachim/frontNebulia --token A3IDDYTQL3TTQEDTYAW7DL3GFIZLS


./run.sh & wait $! 