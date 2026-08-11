FROM node:20

WORKDIR /usr/src/app

COPY frontend/src/package.json .

RUN npm install

COPY frontend/src/ .

ENV PORT=8080

EXPOSE 8080

CMD ["npm","start"]