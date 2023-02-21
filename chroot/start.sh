#!/bin/sh
set -e
username=${2:-debian}
systemd-nspawn -u $username -D $1
