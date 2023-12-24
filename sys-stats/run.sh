#!/bin/sh
set -x
backendhost=${BACKEND_HOST:-"http://localhost:5000"}
rawbackend=$(echo "${backendhost}" | sed 's/\//\\\//g')
find /usr/share/nginx/html -type f -exec sed -i "s/http:\/\/localhost:5000/$rawbackend/g" {} \;
nginx -g "daemon off;"