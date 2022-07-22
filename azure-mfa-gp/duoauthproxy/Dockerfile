FROM debian:latest as builder

RUN apt-get update -qy && apt-get install -qy build-essential libffi-dev perl zlib1g-dev wget

WORKDIR /opt
RUN wget --content-disposition https://dl.duosecurity.com/duoauthproxy-latest-src.tgz
WORKDIR /opt/duoauthproxy
RUN tar xzf /opt/duoauthproxy-5.7.0-src.tgz && \
    mv duoauthproxy*/* . && \
    make

FROM debian:latest
COPY --from=builder /opt/duoauthproxy/duoauthproxy-build /tmp/duoauthproxy-build
RUN /tmp/duoauthproxy-build/install --install-dir /opt/duoauthproxy --service-user duo_authproxy_svc --log-group duo_authproxy_grp --create-init-script yes
RUN rm -rf /tmp/duoauthproxy-build

ENTRYPOINT [ "/opt/duoauthproxy/bin/authproxyctl" ]
CMD [ "start" ]