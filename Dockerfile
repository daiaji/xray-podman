FROM alpine AS builder
LABEL maintainer "Darian Raymond <admin@v2ray.com>"


WORKDIR /root
COPY v2ray.sh /root/v2ray.sh
RUN set -ex \
  && apk add --no-cache tzdata openssl ca-certificates curl \
  && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
  && chmod +x /root/v2ray.sh \
  && /root/v2ray.sh \
  && curl -fsSLo /usr/local/share/v2ray/h2y.dat https://raw.githubusercontent.com/ToutyRater/V2Ray-SiteDAT/master/geofiles/h2y.dat


FROM scratch


COPY --from=builder /usr/bin/v2ray /usr/bin/v2ctl /usr/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/v2ray/config.json /etc/v2ray/config.json
COPY --from=builder /usr/local/share/v2ray/geosite.dat /usr/local/share/v2ray/geoip.dat /usr/local/share/v2ray/h2y.dat /usr/local/share/v2ray/

ENTRYPOINT [ "v2ray" ]
CMD [ "-config", "/etc/v2ray/config.json" ]
