FROM caddy:2.9.1-alpine

RUN apk add curl --no-cache

COPY ./conf/caddy-config-loader.json /etc/caddy/caddy-config-loader.json

CMD ["caddy", "run", "--config", "/etc/caddy/caddy-config-loader.json"]