FROM node:16-alpine AS development
USER node
WORKDIR /home/node

COPY --chown=node:node package*.json ./

RUN npm install

COPY --chown=node:node . .

RUN npm run build

FROM node:16-alpine AS production-builder

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /home/node

COPY package*.json ./
RUN npm install --only=production

FROM node:16-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /home/node
COPY --from=production-builder /home/node/node_modules ./node_modules
COPY --from=development /home/node/package.json ./
COPY --from=development /home/node/dist ./
COPY --from=development /home/node/dist/migrations ./dist/migrations
CMD ["/bin/sh", "-c", "node ./node_modules/typeorm/cli.js migration:run && node src/main"]