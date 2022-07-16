FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer "V2Fly Community <dev@v2fly.org>"


WORKDIR /root
ARG TARGETPLATFORM
ARG TAG
COPY xray.sh /root/xray.sh


RUN set -ex \
	&& apk add --no-cache tzdata openssl ca-certificates curl \
	&& mkdir -p /etc/xray /usr/local/share/xray /var/log/xray \
	&& chmod +x /root/xray.sh \
	&& /root/xray.sh "${TARGETPLATFORM}" "${TAG}"

ENTRYPOINT [ "xray" ]
CMD [ "-config", "/etc/xray/config.json" ]
