#!/bin/bash
cd "$(dirname "$0")/.."

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
function check_dependency() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}Error:${NC} $1 is not installed. Please install $1 first."
    exit 1
  fi
}

function wait_for_db() {
  echo "Waiting for the database to become available..."
  until docker-compose exec db pg_isready &> /dev/null; do
    sleep 1
  done
}

# Check dependencies
check_dependency docker
check_dependency docker-compose

# Build Docker images and start containers
echo -e "${GREEN}Building Docker images and starting containers...${NC}"
docker-compose build
docker-compose up -d

# Wait for the database to become available
wait_for_db

# Ensure the database is created and has the correct schema
echo -e "${GREEN}Setting up the database...${NC}"
docker-compose exec web bundle exec rails db:create db:migrate db:seed

echo -e "${GREEN}Setup completed. Removing containers...${NC}"
docker-compose down

echo -e "${GREEN}Setup completed. You can now start the app with ./scripts/start.sh${NC}"
