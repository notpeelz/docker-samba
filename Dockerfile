FROM alpine:3.17

# If any dependencies fail, the entire supervision tree should fail
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
# Prevent services from timing out
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

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

COPY ./data/config/s6/s6-rc.d /etc/s6-overlay/s6-rc.d
COPY ./data/scripts /scripts

EXPOSE 139 445
ENTRYPOINT ["/init"]
