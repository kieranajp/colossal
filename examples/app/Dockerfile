FROM quay.io/ahelal/colossal:dev

ADD app.py /
ADD requirements.txt /
ADD preStop.sh /hooks/preStop
ADD stop.sh /hooks/stop
ADD postStop.sh /hooks/postStop

# Application will be announced to consul as "pilot-app
ENV APP_NAME          "pilot-app"
ENV APP_PORT          9000
# Tags to be announced in consul
ENV APP_TAGS          "pilot-app,v1.1.1"
# Command to run our application. We will run it as app user
ENV APP_EXEC          resu app:app -- python /app.py
# Health check config for consul
ENV APP_HEALTH_EXEC   "curl -fsSo /dev/null http://127.0.0.1:9000"
# Attempts to restart the process if it exists
ENV APP_RESTARTS      10

RUN apk add --no-cache  curl bash openrc python py-pip
RUN pip install -r /requirements.txt \
    && pip install -r /requirements.txt

RUN rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

# ADD env.ctmpl /hooks/ConfigENV.ctmpl
# ADD r /hooks/renderConfigFiles

#ADD DIE /hooks/preStart

EXPOSE 9000
