FROM node:8.11.3

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

ENV PATH=$PATH:/home/node/.npm-global/bin

RUN mkdir /app
WORKDIR /app

RUN apt-get update && npm install -g yarn
