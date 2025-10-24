#!/bin/bash
# Resource cleanup script for smart chatbot

set -e

AWS_ACCOUNT_ID="907849381252"
BUCKET_NAME="smart-chatbot-terraform-state-${AWS_ACCOUNT_ID}"
TABLE_NAME="terraform-state-lock"

echo "Cleaning up smart chatbot resources..."

# Destroy Terraform infrastructure
cd terraform
terraform destroy -auto-approve

cd ..

# Remove S3 bucket
echo "Removing S3 bucket..."
aws s3 rb s3://${BUCKET_NAME} --force

# Remove DynamoDB table
echo "Removing DynamoDB table..."
aws dynamodb delete-table --table-name ${TABLE_NAME}

# Remove deployment package
rm -f terraform/lambda_function.zip

# Remove node modules and coverage reports
rm -rf lambda/node_modules
rm -rf lambda/coverage

# Remove any test reports
rm -f lambda/test-report.xml

echo "Resource cleanup complete!"