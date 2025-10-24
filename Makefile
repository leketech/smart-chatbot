# Convenience commands for smart chatbot

AWS_ACCOUNT_ID ?= 907849381252

.PHONY: setup test deploy destroy clean plan validate format lint help logs deploy-dev deploy-prod

help:
	@echo "Smart Chatbot Makefile Commands"
	@echo "============================"
	@echo "make setup          - One-time setup"
	@echo "make install        - Install Lambda dependencies"
	@echo "make test           - Run tests"
	@echo "make lint           - Run linter"
	@echo "make format         - Format code with Prettier"
	@echo "make validate       - Run all checks (lint, format, tests)"
	@echo "make package        - Create deployment package"
	@echo "make plan           - Show deployment plan"
	@echo "make deploy-dev     - Deploy to development"
	@echo "make deploy-prod    - Deploy to production"
	@echo "make deploy         - Deploy the infrastructure"
	@echo "make destroy        - Destroy all resources"
	@echo "make logs           - View Lambda logs"
	@echo "make clean          - Clean build artifacts"
	@echo "make help           - Show this help message"

setup: install package
	cd terraform && terraform init
	cd terraform && terraform apply -auto-approve -var="environment=dev"

test:
	cd lambda && npm test

plan:
	cd terraform && terraform plan

deploy:
	cd terraform && terraform apply -auto-approve

deploy-dev:
	cd terraform && terraform apply -auto-approve -var="environment=dev"

deploy-prod:
	cd terraform && terraform apply -auto-approve -var="environment=prod"

destroy:
	cd terraform && terraform destroy -auto-approve

clean:
	./scripts/cleanup.sh

lint:
	cd lambda && npm run lint

format:
	cd lambda && npm run format

validate:
	cd lambda && npm run validate

install:
	cd lambda && npm install

package:
	cd lambda && npm run package

logs:
	@echo "Viewing Lambda logs..."
	aws logs tail /aws/lambda/smart-chatbot-dev-handler --follow