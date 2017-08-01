#!/bin/sh
/usr/local/bin/consul-template \
    -consul-addr "${CONSUL_ADDR}":8500  \
    -once \
    -dedup \
    -template "/etc/nginx_template.conf.ctmpl:/etc/nginx/conf.d/default.conf"
