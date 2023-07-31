#!/usr/bin/with-contenv /bin/bash
# vim:ft=sh

set -Eeuo pipefail

INITIALIZED="/.initialized"

if [[ ! -f "$INITIALIZED" ]]; then
  echo "SAMBA CONFIG: initializing"
  cat > /etc/samba/smb.conf <<- '  EOF'
    [global]
    server role = standalone server

    security = user
    passdb backend = smbpasswd
    obey pam restrictions = no

    load printers = no
    printcap name = /dev/null

    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288
    dns proxy = no
    wide links = yes
    follow symlinks = yes
    unix extensions = no
    acl allow execute always = yes
  EOF

  if [[ -z "${SAMBA_CONF_LOG_LEVEL+x}" ]]; then
    SAMBA_CONF_LOG_LEVEL="1"
    echo "SAMBA CONFIG: no \$SAMBA_CONF_LOG_LEVEL set, using '$SAMBA_CONF_LOG_LEVEL'"
  fi
  echo 'log level = '"$SAMBA_CONF_LOG_LEVEL" >> /etc/samba/smb.conf

  if [[ -z "${SAMBA_CONF_WORKGROUP+x}" ]]; then
    SAMBA_CONF_WORKGROUP="WORKGROUP"
    echo "SAMBA CONFIG: no \$SAMBA_CONF_WORKGROUP set, using '$SAMBA_CONF_WORKGROUP'"
  fi
  echo 'workgroup = '"$SAMBA_CONF_WORKGROUP" >> /etc/samba/smb.conf

  if [[ -z "${SAMBA_CONF_SERVER_STRING+x}" ]]; then
    SAMBA_CONF_SERVER_STRING="Samba Server"
    echo "SAMBA CONFIG: no \$SAMBA_CONF_SERVER_STRING set, using '$SAMBA_CONF_SERVER_STRING'"
  fi
  echo 'server string = '"$SAMBA_CONF_SERVER_STRING" >> /etc/samba/smb.conf

  if [[ -z "${SAMBA_CONF_MAP_TO_GUEST+x}" ]]; then
    SAMBA_CONF_MAP_TO_GUEST="Bad User"
    echo "SAMBA CONFIG: no \$SAMBA_CONF_MAP_TO_GUEST set, using '$SAMBA_CONF_MAP_TO_GUEST'"
  fi
  echo 'map to guest = '"$SAMBA_CONF_MAP_TO_GUEST" >> /etc/samba/smb.conf

  echo >> /etc/samba/smb.conf

  echo "$SAMBA_CONF" >> /etc/samba/smb.conf

  for line in "$USERS_CONF"; do
    [[ -z "$line" ]] && continue

    IFS=':' read user uid pwdhash <<< "$line"
    echo "ACCOUNT: adding account '$user' with UID $uid"

    adduser -D -H -u "$uid" -s /bin/false "$user"
    if [[ -n "${pwdhash:-}" ]]; then
      smbpasswd -a -n "$user" > /dev/null
      pdbedit -c='[]' --set-nt-hash="$pwdhash" "$user" > /dev/null
      smbpasswd -e "$user"

      # print user info
      pdbedit -r "$user"
    fi
  done

  touch "$INITIALIZED"
fi

if [[ ! -s "/etc/samba/smb.conf" ]]; then
  echo "ERROR: samba config is empty or does not exist"
  exit 1
fi

testparm -s &> /dev/null
exitcode=$?
if [[ "$exitcode" -gt 0 ]]; then
  echo "ERROR: failed parsing samba config (exitcode $exitcode)"
  exit 1
fi
