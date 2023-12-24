FROM node:21.4-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
COPY run.sh /usr/local/bin/
ENTRYPOINT [ "run.sh" ]