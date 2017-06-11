FROM alpine:3.6

## All this option must be passeed during build time
ARG VERSION
ARG CONTAINERPILOT_VERSION
ARG CONTAINERPILOT_CHECKSUM
ARG CONSUL_VERSION
ARG CONSUL_CHECKSUM
ARG CONSUL_TEMPLATE_VERSION
ARG CONSUL_TEMPLATE_CHECKSUM
ARG RESU_VERSION
ARG RESU_CHECKSUM
ARG PROMETHEUS_HAPROXY_VERSION
ARG PROMETHEUS_HAPROXY_CHECKSUM

# Download all packages
ADD https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz /tmp/containerpilot.tar.gz
ADD https://github.com/ben--/resu/releases/download/${RESU_VERSION}/resu-alpine /sbin/resu
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip /tmp/consul.zip
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp/consul-template.zip
ADD https://github.com/ben--/resu/releases/download/${RESU_VERSION}/resu-alpine /sbin/resu
ADD https://github.com/prometheus/haproxy_exporter/releases/download/v${PROMETHEUS_HAPROXY_VERSION}/haproxy_exporter-${PROMETHEUS_HAPROXY_VERSION}.linux-amd64.tar.gz /tmp/haproxy_exporter.tar.gz

RUN set -ex \
    && echo "# CONTAINERPILOT" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && echo "# CONSUL" \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && adduser -D consul \
    && mkdir -p /consul/config \
    && mkdir -p /consul/data \
    && chown -R consul /consul \
    && echo "# Consul-template" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && mkdir -p /consul/template \
    && rm /tmp/consul-template.zip \
    && echo "# resu" \
    && echo "${RESU_CHECKSUM}  /sbin/resu" | sha256sum -c \
    && chmod +x /sbin/resu \
    && adduser -D app \
    && echo "#Prometheus HAproxy exporter" \
    && echo "${PROMETHEUS_HAPROXY_CHECKSUM}  /tmp/haproxy_exporter.tar.gz" | sha256sum -c \
    && tar zxvf /tmp/haproxy_exporter.tar.gz -C /tmp \
    && cp /tmp/haproxy_exporter-${PROMETHEUS_HAPROXY_VERSION}.linux-amd64/haproxy_exporter /bin/haproxy_exporter \
    && rm -rf /tmp/haproxy_exporter.tar.gz /tmp/haproxy_exporter-${PROMETHEUS_HAPROXY_VERSION}.linux-amd64 \
    && echo "# Set our version file" \
    && printf "name=%s\nimage=%s\nPilot=%s\nConsul=%s\nConsul-template=%s\n" \
              "Colossal" "${VERSION}" "${CONTAINERPILOT_VERSION}" \
              "consumer_producer" "${VERSION}" "${CONTAINERPILOT_VERSION}" \
              "${CONSUL_VERSION}" "${CONSUL_TEMPLATE_VERSION}" > /VERSION

# Install HAproxy and make hooks dir
RUN apk --no-cache add haproxy \
    && mkdir -p /hooks/ \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

# Copy haproxy HCL template,hooks and haproxy reload
COPY etc /etc
COPY bin /usr/local/bin/
COPY hooks /usr/local/bin/


CMD [ "/bin/containerpilot", "-config", "/etc/containerpilot.json5"]
