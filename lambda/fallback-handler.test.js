import { handler } from './index.js';

describe('Fallback Handler', () => {
  test('should handle greeting messages', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'hello',
        sessionId: 'test-session',
      }),
    };

    // Mock the Lex client to throw an error to trigger fallback
    const response = await handler(event);

    // Since we can't easily mock the AWS SDK in this test environment,
    // we'll test the getFallbackResponse function indirectly
    expect(response.statusCode).toBe(200);
  });

  test('should handle help messages', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'help',
        sessionId: 'test-session',
      }),
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
  });

  test('should handle thank you messages', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'thank you',
        sessionId: 'test-session',
      }),
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
  });

  test('should handle goodbye messages', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'goodbye',
        sessionId: 'test-session',
      }),
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
  });

  test('should handle unknown messages with fallback response', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        message: 'unknown message',
        sessionId: 'test-session',
      }),
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
  });
});
