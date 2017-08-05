FROM quay.io/ahelal/colossal:dev

# Application will be announced to consul as "pilot-hooks
ENV  APP_NAME        "pilot-hooks"
ENV  APP_PORT        3030
ENV  APP_EXEC        "/app.sh"
ENV  APP_HEALTH_EXEC "/bin/true"

# no real dependicies just for testing
ENV  SERVICE_NAME_1  "containerpilot"
ENV  SERVICE_PORT_1  "3000"

ADD app.sh /app.sh
ADD hook-test.sh /hook-test.sh
ADD configENV.ctmpl /hooks/configENV.ctmpl

RUN apk add --update-cache curl

## Link test hooks hooks
RUN ln -sf /hook-test.sh /hooks/preStart \
    && ln -sf /hook-test.sh /hooks/renderConfigFiles \
    && ln -sf /hook-test.sh /hooks/preChange \
    && ln -sf /hook-test.sh /hooks/postChange \
    && ln -sf /hook-test.sh /hooks/preStop \
    && ln -sf /hook-test.sh /hooks/postStop

RUN rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

EXPOSE 3030
