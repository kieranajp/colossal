FROM quay.io/ahelal/colossal:dev

# Application will be announced to consul as "pilot-app
ENV  CONSUL          "pilot-consul"
ENV  APP_NAME        "pilot-redis"
ENV  APP_PORT        6379
ENV  APP_EXEC        "redis-server /etc/redis.conf"
ENV  APP_HEALTH_EXEC "redis-cli ping"

RUN apk add --update-cache redis curl

RUN sed -i -- 's/protected-mode yes/protected-mode no/g' /etc/redis.conf \
    && sed -i -- 's/^bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis.conf \
    && sed -i -- 's/daemonize yes/daemonize no/g' /etc/redis.conf

RUN rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

EXPOSE 6379
EXPOSE 3212
