FROM quay.io/ahelal/colossal:dev

ADD nginx_template.conf.ctmpl /etc/nginx_template.conf.ctmpl
ADD renderConfigFiles.sh /hooks/renderConfigFiles
ADD nginx-start.sh /nginx-start.sh

# ADD preStop.sh /hooks/preStop
# ADD stop.sh /hooks/stop
# ADD postStop.sh /hooks/postStop

# Application will be announced to consul as "pilot-app
 ENV  CONSUL          "pilot-consul"
 ENV  APP_NAME        "pilot-nginx"
 ENV  APP_PORT        8888
 ENV  APP_EXEC        "/nginx-start.sh"
 ENV  APP_HEALTH_EXEC "curl -fsSo /dev/null http://127.0.0.1:8888/status"
 # Dependicies
 ENV  SERVICE_NAME_1  "pilot-app"
 ENV  SERVICE_PORT_1  "9000"
 ENV  SERVICE_MODE_1  "http"
 ENV  HAPROXY_STATS   "yes"
 ENV  MYTEST          "MYTEST"

RUN apk add --update-cache curl bash openrc nginx \
    && mkdir -p /run/nginx/

RUN rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

EXPOSE 80
EXPOSE 3212