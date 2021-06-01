FROM alpine:latest as builder

RUN apk add --no-cache build-base linux-headers git bash make openssl-dev && \
    git clone https://github.com/pymumu/smartdns.git --depth 1 && \
    cd smartdns && \
    make

RUN git clone https://github.com/Yelp/dumb-init.git --depth 1 && \
    cd dumb-init && \
    make

FROM alpine:latest

RUN apk add --no-cache ca-certificates openssl
COPY --from=builder /smartdns/src/smartdns /usr/sbin/smartdns
COPY --from=builder /dumb-init/dumb-init /usr/bin/dumb-init

RUN chmod 755 /usr/sbin/smartdns /usr/bin/dumb-init

#EXPOSE 53/udp
VOLUME "/etc/smartdns/"

CMD ["/usr/bin/dumb-init", "--", "/usr/sbin/smartdns", "-f"]
