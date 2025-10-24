import { handler } from './index.js';

describe('Lambda Handler', () => {
  test('should return a successful response for API Gateway event', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'hello',
        sessionId: 'test-session'
      })
    };

    const response = await handler(event);
    
    expect(response.statusCode).toBe(200);
    expect(response.headers['Content-Type']).toBe('application/json');
    expect(response.headers['Access-Control-Allow-Origin']).toBe('*');
    
    const body = JSON.parse(response.body);
    expect(body.sessionId).toBe('test-session');
  });

  test('should return an error response for missing message', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        sessionId: 'test-session'
      })
    };

    const response = await handler(event);
    
    expect(response.statusCode).toBe(400);
    expect(response.headers['Content-Type']).toBe('application/json');
    expect(response.headers['Access-Control-Allow-Origin']).toBe('*');
    
    const body = JSON.parse(response.body);
    expect(body.error).toBe('Message is required');
  });

  test('should handle Lex events', async () => {
    const event = {
      invocationSource: 'DialogCodeHook',
      sessionState: {
        intent: {
          name: 'CustomGreetingIntent'
        }
      }
    };

    const response = await handler(event);
    
    expect(response.sessionState.dialogAction.type).toBe('Close');
    expect(response.sessionState.intent.name).toBe('CustomGreetingIntent');
    expect(response.sessionState.intent.state).toBe('Fulfilled');
    expect(response.messages[0].contentType).toBe('PlainText');
    expect(response.messages[0].content).toContain('Hello! Welcome to our smart chatbot');
  });
});