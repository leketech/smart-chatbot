// Lambda handler for smart chatbot with Lex integration
import {
  LexRuntimeV2Client,
  RecognizeTextCommand,
} from '@aws-sdk/client-lex-runtime-v2';

// Create Lex client
const lexClient = new LexRuntimeV2Client({
  region: process.env.AWS_REGION || 'us-east-1',
});

export const handler = async event => {
  // eslint-disable-next-line no-console
  console.log('Received event:', JSON.stringify(event, null, 2));

  // Handle API Gateway events
  if (event.httpMethod) {
    return handleApiGatewayEvent(event);
  }

  // Check if this is a Lex event
  if (event.invocationSource) {
    return handleLexEvent(event);
  }

  // Default response
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      message: 'Hello from smart chatbot!',
      input: event,
    }),
  };

  return response;
};

async function handleApiGatewayEvent(event) {
  let body;
  try {
    body = JSON.parse(event.body);
  } catch (_) {
    body = {};
  }

  const { message, sessionId = 'default-session' } = body;

  if (!message) {
    return {
      statusCode: 400,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        error: 'Message is required',
      }),
    };
  }

  try {
    // Call Lex to process the message
    const lexParams = {
      botId: process.env.LEX_BOT_ID,
      botAliasId: process.env.LEX_BOT_ALIAS_ID,
      localeId: 'en_US',
      sessionId: sessionId,
      text: message,
    };

    // eslint-disable-next-line no-console
    console.log('Calling Lex with params:', JSON.stringify(lexParams, null, 2));

    const command = new RecognizeTextCommand(lexParams);
    const lexResponse = await lexClient.send(command);

    // eslint-disable-next-line no-console
    console.log('Lex response:', JSON.stringify(lexResponse, null, 2));

    // Extract the message from Lex response
    let responseMessage = "Sorry, I didn't understand that. Can you please rephrase?";
    if (lexResponse.messages && lexResponse.messages.length > 0) {
      responseMessage = lexResponse.messages[0].content;
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: responseMessage,
        sessionId: sessionId,
      }),
    };
  } catch (_) {
    // eslint-disable-next-line no-console
    console.error('Error calling Lex:');

    // Fallback to simple response logic
    return getFallbackResponse(message);
  }
}

function handleLexEvent(event) {
  let message = '';

  switch (event.sessionState.intent.name) {
    case 'CustomGreetingIntent':
      message =
        'Hello! Welcome to our smart chatbot. How can I help you today?';
      break;
    case 'CustomHelpIntent':
      message =
        'I can help you with general questions. You can ask me about our services, products, or just chat with me!';
      break;
    default:
      message = "I'm sorry, I didn't understand that. Can you please rephrase?";
      break;
  }

  return {
    sessionState: {
      dialogAction: {
        type: 'Close',
      },
      intent: {
        name: event.sessionState.intent.name,
        state: 'Fulfilled',
      },
    },
    messages: [
      {
        contentType: 'PlainText',
        content: message,
      },
    ],
  };
}

function getFallbackResponse(message) {
  // Simple intent recognition based on keywords
  const lowerMessage = message.toLowerCase();

  if (
    lowerMessage.includes('hello') ||
    lowerMessage.includes('hi') ||
    lowerMessage.includes('hey')
  ) {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Hello! Welcome to our smart chatbot. How can I help you today?',
        sessionId: 'default-session',
      }),
    };
  } else if (lowerMessage.includes('help')) {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message:
          'I can help you with general questions. You can ask me about our services, products, or just chat with me!',
        sessionId: 'default-session',
      }),
    };
  } else if (lowerMessage.includes('thank')) {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: "You're welcome! Is there anything else I can help you with?",
        sessionId: 'default-session',
      }),
    };
  } else if (
    lowerMessage.includes('bye') ||
    lowerMessage.includes('goodbye')
  ) {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message:
          'Goodbye! Feel free to come back if you have more questions.',
        sessionId: 'default-session',
      }),
    };
  } else {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: "I'm sorry, I didn't understand that. Can you please rephrase?",
        sessionId: 'default-session',
      }),
    };
  }
}