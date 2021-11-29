ARG ALPINE_VERSION=3.14
FROM alpine:${ALPINE_VERSION}

RUN apk add --update --no-cache \
  s6-overlay \
  bash \
  samba

RUN mkdir -p /var/lib/samba/private/ \
  && mkdir --mode=0700 -p /usr/local/samba/var/cores \
  && touch /var/lib/samba/registry.tdb \
    /var/lib/samba/account_policy.tdb \
    /var/lib/samba/winbindd_idmap.tdb \
  && rm /etc/samba/smb.conf

COPY ./data /data

COPY ./data/config/s6/cont-init.d /etc/cont-init.d
COPY ./data/config/s6/services.d /etc/services.d

EXPOSE 139 445
ENTRYPOINT ["/init"]
