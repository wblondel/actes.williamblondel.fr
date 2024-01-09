FROM caddy:2.7.6-alpine

RUN apk add bash --no-cache

COPY caddy-config-loader.json /etc/caddy/caddy-config-loader.json
COPY start.sh /start.sh

CMD /start.sh