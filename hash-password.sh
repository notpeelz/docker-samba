#!/usr/bin/env bash

echo -n "Password: "
read -s password
echo
# this creates an LM hash
echo -n "$password"|iconv -f ASCII -t UTF16LE|openssl dgst -md4|awk '{print $2}'
