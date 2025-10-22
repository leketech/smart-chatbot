#!/bin/bash
# Resource cleanup script for smart chatbot

set -e

echo "Cleaning up smart chatbot resources..."

# Destroy Terraform infrastructure
cd terraform
terraform destroy -auto-approve

# Remove deployment package
cd ..
rm -f terraform/lambda_function.zip

# Remove node modules and coverage reports
rm -rf lambda/node_modules
rm -rf lambda/coverage

# Remove any test reports
rm -f lambda/test-report.xml

echo "Resource cleanup complete!"