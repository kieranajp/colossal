FROM quay.io/ahelal/colossal:dev

ADD app.py /
ADD requirements.txt /
ADD configENV.ctmpl /hooks/configENV.ctmpl


# Application will be announced to consul as "pilot-app
ENV APP_NAME          "pilot-app"
ENV APP_PORT          8889
# Tags to be announced in consul
ENV APP_TAGS          "TEST,v1.1.1,Development"
# Command to run our application. We will run it as app user
ENV APP_EXEC          resu app:app -- python /app.py
# Health check config for consul
ENV APP_HEALTH_EXEC   "curl -fsSo /dev/null http://127.0.0.1:8889"
# Attempts to restart the process if it exists
ENV APP_RESTARTS      1

## Service dependency
ENV SERVICE_NAME_23   "pilot-redis"
ENV SERVICE_PORT_23   "6379"
ENV SERVICE_MODE_23   "tcp"

## HA Proxy config (need to be tested)
ENV HAPROXY_STATS     True
ENV HAPROXY_EXPORTER  True

RUN apk add --update-cache curl python py-pip
RUN pip install -r /requirements.txt
RUN rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

EXPOSE 8889
