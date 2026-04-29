FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache postgresql-client netcat-openbsd

COPY package*.json ./
RUN npm install

COPY . .

CMD ["node", "server.mjs"]
