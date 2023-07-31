#!/usr/bin/env bash

echo -n "Password: "
read -s password
echo
# create an LM hash
echo -n "$password" \
  | iconv -f ASCII -t UTF16LE \
  | openssl dgst -provider legacy -md4 \
  | awk '{ print $2 }'
