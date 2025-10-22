// Lambda handler for smart chatbot with Lex integration

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  
  // Check if this is a Lex event
  if (event.invocationSource) {
    return handleLexEvent(event);
  }
  
  // Handle API Gateway events
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      message: 'Hello from smart chatbot!',
      input: event
    })
  };
  
  return response;
};

function handleLexEvent(event) {
  let message = '';
  
  switch (event.sessionState.intent.name) {
    case 'GreetingIntent':
      message = 'Hello! Welcome to our smart chatbot. How can I help you today?';
      break;
    case 'HelpIntent':
      message = 'I can help you with general questions. You can ask me about our services, products, or just chat with me!';
      break;
    default:
      message = "I'm sorry, I didn't understand that. Can you please rephrase?";
  }
  
  return {
    sessionState: {
      dialogAction: {
        type: 'Close'
      },
      intent: {
        name: event.sessionState.intent.name,
        state: 'Fulfilled'
      }
    },
    messages: [
      {
        contentType: 'PlainText',
        content: message
      }
    ]
  };
};