#!/usr/bin/env bash

result="$(df "$1"|tail -1)"
used="$(echo "$result"|awk '{print $(NF-3)}')"
total="$(echo "$result"|awk '{print $(NF-2)}')"
free="$((total - used))"
echo "$total $free"
