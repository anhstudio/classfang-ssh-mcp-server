FROM node:22-alpine AS builder
WORKDIR /build
COPY package.json package-lock.json* tsconfig.json ./
RUN npm install
COPY src ./src
COPY scripts ./scripts
RUN node scripts/build.js

FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --omit=dev && npm cache clean --force
COPY --from=builder /build/build ./build
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
