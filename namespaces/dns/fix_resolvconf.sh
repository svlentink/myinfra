#!/bin/sh

cat /etc/resolv.conf > /etc/resolv.conf.bak
rm -f /etc/resolv.conf

cat << EOF >> /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
EOF

chattr +i /etc/resolv.conf

