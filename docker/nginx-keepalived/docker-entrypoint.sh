#!/bin/bash
set -e

echo "Starting Nginx Load Balancer..."

exec nginx -g "daemon off;"
