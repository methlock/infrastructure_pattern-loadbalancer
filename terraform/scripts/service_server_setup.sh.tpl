#!/bin/bash

# just to be sure that terraform is not too quick
sleep 5

# install new metric agent from DO
#sudo apt-get purge do-agent
#curl -sSL https://insights.nyc3.cdn.digitaloceanspaces.com/install.sh | sudo bash

# initial setup
mkdir /etc/service
