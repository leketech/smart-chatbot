import { handler } from './index.js';

describe('Lex Handler', () => {
  test('should handle CustomGreetingIntent', async () => {
    const event = {
      invocationSource: 'DialogCodeHook',
      sessionState: {
        intent: {
          name: 'CustomGreetingIntent',
        },
      },
    };

    const response = await handler(event);

    expect(response.messages[0].content).toContain(
      'Hello! Welcome to our smart chatbot',
    );
  });

  test('should handle CustomHelpIntent', async () => {
    const event = {
      invocationSource: 'DialogCodeHook',
      sessionState: {
        intent: {
          name: 'CustomHelpIntent',
        },
      },
    };

    const response = await handler(event);

    expect(response.messages[0].content).toContain(
      'I can help you with general questions',
    );
  });

  test('should handle unknown intents with fallback response', async () => {
    const event = {
      invocationSource: 'DialogCodeHook',
      sessionState: {
        intent: {
          name: 'UnknownIntent',
        },
      },
    };

    const response = await handler(event);

    expect(response.messages[0].content).toContain(
      "I'm sorry, I didn't understand that",
    );
  });
});