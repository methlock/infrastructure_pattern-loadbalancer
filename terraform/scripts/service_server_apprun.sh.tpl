#!/bin/bash

sleep 5

cd /etc/service
docker build -f Dockerfile-service -t service_demo .
docker run --name service_demo -d -p 5000:5000 -e DB_HOST=${DB_IP} service_demo
