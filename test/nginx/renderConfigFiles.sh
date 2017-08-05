#!/bin/sh
/usr/local/bin/consul-template \
    -consul-addr localhost:8500  \
    -once \
    -dedup \
    -template "/etc/nginx_template.conf.ctmpl:/etc/nginx/conf.d/default.conf"
