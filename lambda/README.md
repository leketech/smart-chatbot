# Smart Chatbot Lambda Function

This directory contains the AWS Lambda function code for the smart chatbot application.

## Functionality

The Lambda function handles two types of events:

1. **API Gateway Events**: Processes chat messages from the web interface
2. **Lex Events**: Handles intents from the Amazon Lex bot

## Environment Variables

- `LEX_BOT_ID`: The ID of the Lex bot
- `LEX_BOT_ALIAS_ID`: The ID of the Lex bot alias
- `ENVIRONMENT`: The deployment environment (dev, prod)
- `LOG_LEVEL`: The logging level (INFO, DEBUG, etc.)

## Dependencies

- `@aws-sdk/client-lex-runtime-v2`: AWS SDK for Lex Runtime V2

## Testing

Run tests with:

```bash
npm test
```

## Linting

Lint the code with:

```bash
npm run lint
```

Fix linting issues with:

```bash
npm run lint:fix
```

## Packaging

Package the function for deployment with:

```bash
npm run package
```