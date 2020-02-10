#!/bin/bash -e

apt-get purge -y aria2

exec rm /usr/local/sbin/apt-fast /etc/apt-fast.conf
