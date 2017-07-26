FROM alpine:3.6

## All this ARGS must be passeed during build time
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

# Add curl for downloading
RUN apk add --update curl ca-certificates

# Create hooks dir and user app
RUN mkdir -p /hooks \
    && adduser -D app

# Container pilot
RUN echo "# CONTAINERPILOT ${CONTAINERPILOT_VERSION} " && echo "" \
    && curl --retry 3 -Lf -o /tmp/containerpilot.tar.gz "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin

# Consul
RUN echo "# CONSUL" && echo "" \
    && curl --retry 3 -Lf -o /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && adduser -D consul \
    && mkdir -p /consul/config \
    && mkdir -p /consul/data \
    && chown -R consul /consul

# Consul template
RUN echo "# Consul-template" && echo "" \
    && curl --retry 3 -Lf -o /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && mkdir -p /consul/template

# Resu
RUN echo "# resu" && echo "" \
    && curl --retry 3 -Lf -o /sbin/resu "https://github.com/ben--/resu/releases/download/${RESU_VERSION}/resu-alpine" \
    && echo "${RESU_CHECKSUM}  /sbin/resu" | sha256sum -c \
    && chmod +x /sbin/resu

# Prometheus HAProxy exporter"
RUN echo "# Prometheus HAproxy exporter" && echo "" \
    && curl --retry 3 -Lf -o /tmp/haproxy_exporter.tar.gz "https://github.com/prometheus/haproxy_exporter/releases/download/v${PROMETHEUS_HAPROXY_VERSION}/haproxy_exporter-${PROMETHEUS_HAPROXY_VERSION}.linux-amd64.tar.gz" \
    && echo "${PROMETHEUS_HAPROXY_CHECKSUM}  /tmp/haproxy_exporter.tar.gz" | sha256sum -c \
    && tar zxvf /tmp/haproxy_exporter.tar.gz -C /tmp \
    && cp /tmp/haproxy_exporter-${PROMETHEUS_HAPROXY_VERSION}.linux-amd64/haproxy_exporter /bin/haproxy_exporter

# Setup versions
RUN  printf "%s=%s\n%s=%s\n%s=%s\n%s=%s\n%s=%s\n%s=%s\n" \
                "Colossal" "${VERSION}" \
                "CONTAINERPILOT"  "${CONTAINERPILOT_VERSION}" \
                "CONSUL" "${CONSUL_VERSION}" \
                "CONSUL_TEMPLATE" "${CONSUL_TEMPLATE_VERSION}" \
                "RESU" "${RESU_VERSION}" \
                "PROMETHEUS_HAPROXY" "${PROMETHEUS_HAPROXY_VERSION}" \
                > /VERSION

# Install HAProxy and some cleanup
RUN apk --no-cache add haproxy

# Do some clean up
RUN echo "# Cleaning up" && echo "" \
    && apk del curl unzip ca-certificates \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache/

# Copy config, bin and hooks
COPY etc /etc
COPY bin /usr/local/bin/
COPY hooks /usr/local/bin/

CMD [ "/usr/local/bin/entryPointScript.sh"]
