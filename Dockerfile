# Dockerfile for local testing of smart chatbot

FROM node:16

WORKDIR /app

COPY lambda/package*.json ./
RUN npm install

COPY lambda/ .

EXPOSE 3000

CMD ["node", "index.js"]