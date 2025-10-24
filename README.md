# 🤖 Smart Chatbot - AWS Serverless Deployment

[![Deploy Status](https://github.com/yourusername/smart-chatbot/workflows/Deploy%20Chatbot%20to%20AWS/badge.svg)](https://github.com/yourusername/smart-chatbot/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready, enterprise-grade chatbot solution built with AWS Lambda, Amazon Lex, deployed using Terraform Infrastructure as Code, and automated with GitHub Actions CI/CD pipeline.

## 🌟 Features

### Core Functionality
- ✅ **Natural Language Understanding** with Amazon Lex V2
- ✅ **Serverless Architecture** using AWS Lambda
- ✅ **RESTful API** via API Gateway
- ✅ **Real-time Conversation** management
- ✅ **Session Tracking** and context preservation

### DevOps & Infrastructure
- ✅ **Infrastructure as Code** with Terraform
- ✅ **Automated CI/CD** with GitHub Actions
- ✅ **Multi-Environment** support (dev, staging, prod)
- ✅ **Security Scanning** with Trivy
- ✅ **Automated Testing** with Jest
- ✅ **Code Quality** checks (ESLint, Prettier)

### Monitoring & Observability
- ✅ **CloudWatch Dashboards** for real-time metrics
- ✅ **Automated Alerts** for errors and throttling
- ✅ **Structured Logging** with request tracing
- ✅ **Performance Monitoring** with X-Ray ready

## 🏗️ Architecture

```
┌──────────┐         ┌─────────────┐         ┌──────────┐
│  Client  │────────▶│ API Gateway │────────▶│  Lambda  │
│   (Web)  │         │   (REST)    │         │ Function │
└──────────┘         └─────────────┘         └─────┬────┘
                                                    │
                                                    ▼
                                              ┌──────────┐
                                              │ Lex Bot  │
                                              │   (NLU)  │
                                              └──────────┘
                                                    │
                                                    ▼
                                              ┌──────────┐
                                              │CloudWatch│
                                              │   Logs   │
                                              └──────────┘
```

## 📋 Prerequisites

Before you begin, ensure you have:

- **AWS Account** with administrative access
- **AWS CLI** v2.0+ installed and configured
- **Terraform** v1.5+ installed
- **Node.js** v18+ and npm
- **Git** and **GitHub** account
- **Make** (optional, for convenience commands)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/smart-chatbot.git
cd smart-chatbot
```

### 2. Setup AWS Backend

```bash
chmod +x scripts/setup-backend.sh
./scripts/setup-backend.sh
```

This creates:
- S3 bucket for Terraform state
- DynamoDB table for state locking
- Proper encryption and security settings

### 3. Configure Terraform Backend

Update `terraform/main.tf` with your S3 bucket name:

```hcl
backend "s3" {
  bucket         = "smart-chatbot-terraform-state-907849381252"  # Update this
  key            = "chatbot/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### 4. Install Dependencies

```bash
cd lambda
npm install
cd ..
```

### 5. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret access key

### 6. Deploy to AWS

**Using Make (recommended):**
```bash
make setup              # One-time setup
make deploy-dev         # Deploy to development
make deploy-prod        # Deploy to production
```

**Or manually:**
```bash
cd terraform
terraform init
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"
```

### 7. Test the Chatbot

After deployment, get your API endpoint:
```bash
cd terraform
terraform output api_endpoint
```

Test with curl:
```bash
curl -X POST https://your-api-endpoint.amazonaws.com/dev/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "hello", "sessionId": "test-session"}'
```

## 📁 Project Structure

```
smart-chatbot/
├── .github/workflows/
│   └── deploy.yml              # CI/CD pipeline
├── terraform/
│   ├── main.tf                 # Main infrastructure
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── monitoring.tf           # CloudWatch monitoring
├── lambda/
│   ├── index.js                # Lambda handler
│   ├── index.test.js           # Unit tests
│   ├── package.json            # Dependencies
│   ├── .eslintrc.json          # Linting rules
│   └── jest.config.js          # Test configuration
├── client/
│   └── index.html              # Web client example
├── scripts/
│   ├── setup-backend.sh        # Backend setup
│   └── cleanup.sh              # Resource cleanup
├── Makefile                    # Convenience commands
├── Dockerfile                  # Local testing
└── README.md                   # This file
```

## 🔧 Available Commands

### Make Commands

```bash
make help           # Show all available commands
make install        # Install Lambda dependencies
make test           # Run tests
make lint           # Run linter
make deploy-dev     # Deploy to development
make deploy-prod    # Deploy to production
make logs           # View Lambda logs
make destroy        # Destroy all resources
make clean          # Clean build artifacts
```

### NPM Scripts (in lambda/)

```bash
npm test            # Run tests with coverage
npm run lint        # Check code quality
npm run lint:fix    # Fix linting issues
npm run format      # Format code with Prettier
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Lint & Test** - Validates code quality and runs tests
2. **Security Scan** - Scans for vulnerabilities with Trivy
3. **Terraform Validate** - Checks infrastructure code
4. **Terraform Plan** - Previews infrastructure changes
5. **Deploy** - Applies changes to AWS (on push to main/develop)
6. **Post-Deploy Tests** - Validates deployment

### Pipeline Triggers

- **Push to `main`** → Deploy to Production
- **Push to `develop`** → Deploy to Development
- **Pull Request** → Run tests and validation only
- **Manual** → Workflow dispatch

## 🧪 Testing

### Unit Tests

```bash
cd lambda
npm test
```

### Integration Tests

```bash
# Test Lambda function directly
aws lambda invoke \
  --function-name smart-chatbot-dev-handler \
  --payload '{"sessionState":{"intent":{"name":"GreetingIntent","slots":{}},"sessionAttributes":{}}}' \
  response.json

cat response.json
```

### Load Testing (optional)

```bash
# Install artillery
npm install -g artillery

# Run load test
artillery quick --count 10 --num 100 https://your-api-endpoint/chat
```

## 📊 Monitoring

### CloudWatch Dashboards

View your dashboard:
```bash
cd terraform
terraform output dashboard_url
```

### View Logs

```bash
# Lambda logs
make logs

# Or with AWS CLI
aws logs tail /aws/lambda/smart-chatbot-dev-handler --follow

# API Gateway logs
aws logs tail /aws/apigateway/smart-chatbot-dev --follow
```

### Metrics

Key metrics monitored:
- Lambda invocations, errors, duration
- API Gateway requests, 4XX, 5XX errors
- Lex conversation success rate
- Response times

## 🔐 Security Best Practices

### Implemented Security Features

✅ **IAM Least Privilege** - Minimal permissions for all roles
✅ **Encryption at Rest** - S3 and DynamoDB encrypted
✅ **Encryption in Transit** - HTTPS only
✅ **API Throttling** - Rate limiting enabled
✅ **CORS Configuration** - Proper origin control
✅ **Secret Management** - GitHub Secrets for credentials
✅ **Vulnerability Scanning** - Automated with Trivy
✅ **CloudWatch Logging** - All requests logged

### Security Recommendations

1. Enable AWS WAF for API Gateway
2. Use AWS Secrets Manager for sensitive data
3. Enable MFA for AWS account
4. Regularly rotate AWS credentials
5. Review CloudWatch logs for anomalies
6. Enable AWS Config for compliance
7. Use VPC endpoints for private access

## 💰 Cost Estimation

### Development Environment (~$5-10/month)

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 1M requests, 256MB, 1s avg | ~$1 |
| Lex | 1,000 text requests | ~$5 |
| API Gateway | 1M requests | ~$3.50 |
| CloudWatch | Logs + Metrics | ~$1 |
| Data Transfer | 1GB | ~$0.10 |

### Production Environment

Costs scale with usage. Use AWS Cost Explorer and set up billing alerts.

## 🐛 Troubleshooting

### Common Issues

**1. Terraform Backend Error**
```bash
# Solution: Initialize backend
./scripts/setup-backend.sh
cd terraform && terraform init
```

**2. Lambda Permission Error**
```bash
# Solution: Verify Lambda can be invoked by Lex
aws lambda get-policy --function-name smart-chatbot-dev-handler
```

**3. Lex Bot Not Responding**
```bash
# Check Lambda logs
aws logs tail /aws/lambda/smart-chatbot-dev-handler --follow

# Test Lambda directly
aws lambda invoke --function-name smart-chatbot-dev-handler \
  --payload file://test-event.json response.json
```

**4. API Gateway CORS Issues**
```bash
# Verify OPTIONS method exists
aws apigateway get-method \
  --rest-api-id YOUR_API_ID \
  --resource-id YOUR_RESOURCE_ID \
  --http-method OPTIONS
```

**5. GitHub Actions Deployment Fails**
```bash
# Check AWS credentials are set correctly
# Verify IAM permissions include:
# - Lambda full access
# - Lex full access
# - API Gateway full access
# - IAM role creation
# - CloudWatch logs
```

## 🔄 Updates and Maintenance

### Updating Lambda Function

```bash
# 1. Update code in lambda/index.js
# 2. Test locally
cd lambda && npm test

# 3. Deploy
make deploy-dev
```

### Adding New Intents

```bash
# 1. Add intent in terraform/main.tf
resource "aws_lexv2models_intent" "new_intent" {
  bot_id      = aws_lexv2models_bot.chatbot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en_us.locale_id
  name        = "NewIntent"
  
  sample_utterance {
    utterance = "sample phrase"
  }
  
  fulfillment_code_hook {
    enabled = true
  }
}

# 2. Add handler in lambda/index.js
function handleNewIntent(event) {
  return createResponse(event, 'Fulfilled', 'Response message');
}

# 3. Deploy
terraform apply
```

### Scaling Considerations

For high traffic:
1. Increase Lambda memory (improves CPU)
2. Enable Lambda reserved concurrency
3. Use Lex automated chatbot designer
4. Implement caching with API Gateway
5. Consider DynamoDB for session storage

## 📚 Documentation

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Amazon Lex V2 Documentation](https://docs.aws.amazon.com/lexv2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure all tests pass
- Keep commits atomic and meaningful

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS for services
- HashiCorp for Terraform
- GitHub for Actions
- The open-source community