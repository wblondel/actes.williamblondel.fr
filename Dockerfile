FROM caddy:2.7.6-alpine

RUN apk add bash curl --no-cache

COPY ./conf/caddy-config-loader.json /etc/caddy/caddy-config-loader.json

CMD ["caddy", "run", "--config", "/etc/caddy/caddy-config-loader.json"]