FROM quay.io/ahelal/colossal:dev

# Application
ENV APP_NAME          "blaaa"
ENV APP_PORT          8089
ENV APP_TAGS          "ssadsad,mvp,test"
ENV APP_EXEC          resu app:app -- /app.sh
ENV MYTEST            "ORIGNAL"
ENV APP_HEALTH_EXEC   "/bin/true"
# HAproxy
ENV  HAPROXY_STATS   "yes"

ADD app.sh /app.sh
ADD export.sh /hooks/preStart

EXPOSE 8089
