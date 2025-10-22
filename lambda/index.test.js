// Unit tests for Lambda handler

const { handler } = require('./index');

describe('Lambda Handler', () => {
  it('should return a successful response for API Gateway events', async () => {
    const event = {
      body: '{"message": "test"}'
    };
    
    const result = await handler(event);
    
    expect(result.statusCode).toBe(200);
    expect(result.headers['Content-Type']).toBe('application/json');
    expect(JSON.parse(result.body).message).toBe('Hello from smart chatbot!');
  });

  it('should handle Lex events', async () => {
    const event = {
      invocationSource: 'DialogCodeHook',
      sessionState: {
        intent: {
          name: 'GreetingIntent'
        }
      }
    };
    
    const result = await handler(event);
    
    expect(result.sessionState).toBeDefined();
    expect(result.messages).toBeDefined();
    expect(result.messages[0].contentType).toBe('PlainText');
  });
});