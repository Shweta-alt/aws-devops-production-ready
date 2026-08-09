#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://localhost:8080/health}"
curl --fail --silent --show-error "$URL" >/dev/null
echo "Health check passed: $URL"
