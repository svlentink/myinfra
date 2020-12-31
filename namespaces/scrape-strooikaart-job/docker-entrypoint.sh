#!/bin/sh

HOUR_IN_NL="`TZ=CET date +%H`"
# this is a fallback for misconfigured timezone on the server
# the strooikaart dailySaltUsed is reset at 19:00 CET
if [ "$HOUR_IN_NL" = "18" ]; then
  echo "Last hour of the day"
else
  echo "Not yet the right hour"
  exit 0
fi

OUTPUT=/output/strooikaart-history.csv

apk add --no-cache curl jq

echo -n "`date +%F`," >> $OUTPUT

curl --silent https://rijkswaterstaatstrooit.nl/api/statistics \
  | jq ".dailySaltUsed" \
  >> $OUTPUT

