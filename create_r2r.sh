#!/bin/bash

echo "Recreating the R2R docker service. This will remove the current container. Yes/No"
read -r confirm

if [[ "$confirm" != "Yes" ]]; then
  echo "Operation cancelled."
  exit 0
fi

# Check if we are in the 'py' subdirectory; if not, navigate to it
if [ "${PWD##*/}" != "py" ]; then
  if [ -d "py" ]; then
    cd py
  else
    echo "'py' directory not found. Exiting."
    exit 1
  fi
fi

# Remove the existing Docker container if it exists
container_name="r2r/deweylearn-r2r"
if [ "$(docker ps -aq -f name=$container_name)" ]; then
  echo "Removing existing Docker container..."
  docker rm -f $container_name
fi

# Source the .env file
source .env

# Build the Docker image
docker build -t r2r/deweylearn-r2r .

# Run the poetry command and automatically answer 'n' to the prompt
echo 'n' | poetry run r2r serve --docker --exclude-postgres --config-path=my_r2r.toml

# After everything is running, clean up unused Docker containers and images
echo "Cleaning up unused Docker resources..."
docker system prune -a -f

echo "We are finished. Check Portainer to check on the services"