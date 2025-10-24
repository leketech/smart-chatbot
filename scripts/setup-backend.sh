#!/bin/bash
# Backend setup script for smart chatbot

set -e

AWS_ACCOUNT_ID="907849381252"
BUCKET_NAME="smart-chatbot-terraform-state-${AWS_ACCOUNT_ID}"
REGION="us-east-1"
TABLE_NAME="terraform-state-lock"

echo "Setting up smart chatbot backend..."

# Check if S3 bucket already exists
if aws s3api head-bucket --bucket ${BUCKET_NAME} 2>/dev/null; then
  echo "S3 bucket ${BUCKET_NAME} already exists, skipping creation"
else
  echo "Creating S3 bucket for Terraform state..."
  aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${REGION}
  
  echo "Enabling versioning on S3 bucket..."
  aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled
  
  echo "Enabling encryption on S3 bucket..."
  aws s3api put-bucket-encryption --bucket ${BUCKET_NAME} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
fi

# Check if DynamoDB table already exists
if aws dynamodb describe-table --table-name ${TABLE_NAME} >/dev/null 2>&1; then
  echo "DynamoDB table ${TABLE_NAME} already exists, skipping creation"
else
  echo "Creating DynamoDB table for state locking..."
  aws dynamodb create-table \
    --table-name ${TABLE_NAME} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
fi

# Install Lambda dependencies
cd lambda
source ~/.nvm/nvm.sh
nvm use 18
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