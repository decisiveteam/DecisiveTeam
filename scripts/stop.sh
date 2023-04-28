#!/bin/bash
cd "$(dirname "$0")/.."

set -e

echo -e "Stopping Decisive Team..."
docker-compose down
echo -e "Decisive Team is now stopped."
