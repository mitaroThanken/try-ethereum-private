FROM mcr.microsoft.com/devcontainers/javascript-node:0-18-bullseye

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    xdg-utils \
    && apt-get autoremove -y \
    && apt-get clean -y  \
    && rm -rf /var/lib/apt/lists/*

USER node
RUN npm install -g truffle@5.8.2 \
    && npm install -g ganache@7.8.0 \
    && npm i -g  npm@">=6.14.15 <9.0.0"
