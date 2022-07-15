FROM alpine AS builder
LABEL maintainer "Darian Raymond <admin@v2ray.com>"


WORKDIR /root
COPY xray.sh /root/xray.sh
RUN set -ex \
  && apk --update add --no-cache tzdata openssl ca-certificates curl \
  && mkdir -p /usr/local/share/xray /var/log/xray \
  && chmod +x /root/xray.sh \
  && /root/xray.sh \
  && curl -fsSLo /usr/local/share/xray/h2y.dat https://raw.githubusercontent.com/ToutyRater/V2Ray-SiteDAT/master/geofiles/h2y.dat


FROM scratch


COPY --from=builder /usr/bin/xray /usr/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/local/share/xray/*.dat /usr/local/share/xray/

ENTRYPOINT [ "xray" ]
CMD [ "-config", "/etc/xray/config.json" ]
