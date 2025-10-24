// Mock the AWS SDK client
jest.mock('@aws-sdk/client-lex-runtime-v2', () => {
  return {
    LexRuntimeV2Client: jest.fn().mockImplementation(() => {
      return {
        send: jest.fn().mockResolvedValue({
          messages: [
            {
              content: 'Mocked response from Lex',
            },
          ],
        }),
      };
    }),
    RecognizeTextCommand: jest.fn().mockImplementation(params => {
      return params;
    }),
  };
});