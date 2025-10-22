#!/bin/bash
# Backend setup script for smart chatbot

set -e

echo "Setting up smart chatbot backend..."

# Install Lambda dependencies
cd lambda
npm install

# Run validation checks
npm run validate

# Create deployment package
npm run package

cd ..

# Initialize Terraform
cd terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

echo "Backend setup complete!"