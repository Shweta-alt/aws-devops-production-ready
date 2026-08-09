#!/usr/bin/env bash
set -euo pipefail
docker build -t aws-devops-demo:latest ./app
docker rm -f aws-devops-demo 2>/dev/null || true
docker run -d --restart unless-stopped --name aws-devops-demo -p 8080:8080 -e APP_ENV="${APP_ENV:-dev}" aws-devops-demo:latest
