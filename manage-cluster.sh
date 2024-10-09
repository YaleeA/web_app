#!/bin/bash

action=$1

if [ $# -eq 0 ]; then
  echo "Please provide an action - Install, Start, Stop or Status"
  exit 1
fi

sudo apt-get update 
sudo apt-get upgrade -y

if [ "$action" == "Install" ]; then
  echo "Installing dependencies"
  # git installation
  sudo apt-get install git -y
  # git --version # verify

  # terraform installation
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt-get install terraform
  # terraform --version # verify

  # Docker installation
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  sudo groupadd docker
  sudo gpasswd -a $USER docker
  newgrp docker
  # docker --version # verify
 
elif [ "$action" == "Start" ]; then
  echo "Starting the cluster"

  # Pull script from GitHub
  git clone https://github.com/YaleeA/web_app.git

  # # Start cluster
  WORK_DIR="./terraform"
  cd "$WORK_DIR" || exit
  terraform init
  terraform plan -out=tfplan
  terraform apply -auto-approve tfplan
  rm -f tfplan
  echo "Terraform applied successfully!"

 
elif [ "$action" == "Stop" ]; then
  echo "Stopping the cluster"

  # Stop cluster
  terraform destroy -auto-approve
  echo "Terraform applied and destroyed successfully!"

elif [ "$action" == "Status" ]; then
  echo "Status of cluster:"

  # Status check
  echo "Listing all running Docker containers:"
  docker ps


  containers=$(docker ps -aq 2>&1)

  if [ -z "$containers" ]; then
    echo "No containers found."
    exit 0
  fi

  echo "Checking status of containers :"
  for container in $containers; do
      status=$(docker inspect -f '{{.State.Status}}' $container)

      if [ "$status" == "running" ]; then
          echo "Container $container is running."
      else
          echo "Container $container is not running. Status: $status"
      fi
      done


  echo "Checking health of containers:"
  for container in $containers; do
      health_status=$(docker inspect -f '{{.State.Health.Status}}' $container)
      
      if [ "$health_status" == "none" ]; then
        echo "No health check defined for container $container."
      else
        echo "Health status for container $container: $health_status"
      fi
      done

else
  echo "Invalid action: $action"
  exit 1
fi


