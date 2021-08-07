FROM alpine:latest as builder

RUN apk add --no-cache build-base linux-headers git bash make openssl-dev && \
    git clone https://github.com/pymumu/smartdns.git --depth 1 && \
    cd smartdns && \
    make && \
    strip /smartdns/src/smartdns

FROM alpine:latest

RUN apk add --no-cache ca-certificates openssl dumb-init
COPY --from=builder /smartdns/src/smartdns /usr/sbin/smartdns

RUN chmod 755 /usr/sbin/smartdns

EXPOSE 53/udp 53/tcp
VOLUME "/etc/smartdns/"

CMD ["/usr/bin/dumb-init", "--", "/usr/sbin/smartdns", "-f"]
