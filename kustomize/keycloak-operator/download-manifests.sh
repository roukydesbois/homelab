#!/bin/bash

# Check that the user has provided a version as a parameter
if [ -z "$1" ]; then
  echo "Please provide a version number as a parameter"
  exit 1
fi

# Store the old manifests in a backup folder timestamped with the current date
mkdir -p backup/$(date +%Y-%m-%d)
mv *.yml backup/$(date +%Y-%m-%d)

# Download the manifests for the specified version
curl -O https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/$1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
curl -O https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/$1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
curl -O https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/$1/kubernetes/kubernetes.yml
