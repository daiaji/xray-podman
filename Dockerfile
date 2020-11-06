FROM alpine AS builder

WORKDIR /root
RUN apk update \
    && apk add --no-cache bash tzdata openssl ca-certificates curl unzip \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    && curl -fsSL https://raw.githubusercontent.com/daiaji/v2fly-podman/master/v2ray.sh | bash \
    && curl -fsSLo /usr/local/share/v2ray/h2y.dat https://raw.githubusercontent.com/ToutyRater/V2Ray-SiteDAT/master/geofiles/h2y.dat

FROM scratch

LABEL maintainer "Darian Raymond <admin@v2ray.com>"

COPY --from=builder /usr/bin/v2ray /usr/bin/v2ctl /usr/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/v2ray/config.json /etc/v2ray/config.json
COPY --from=builder /usr/local/share/v2ray/geosite.dat /usr/local/share/v2ray/geoip.dat /usr/local/share/v2ray/h2y.dat /usr/local/share/v2ray/

VOLUME /etc/v2ray
ENTRYPOINT [ "v2ray" ]
CMD [ "-config", "/etc/v2ray/config.json" ]
