FROM node:20

WORKDIR /usr/src/app

COPY backend/src/package.json .

RUN npm install

COPY backend/src .

EXPOSE 3000

CMD  ["node", "server.js"]