#!/bin/sh

apk --no-cache add bind
named -c /etc/named.conf -g -u root # named

