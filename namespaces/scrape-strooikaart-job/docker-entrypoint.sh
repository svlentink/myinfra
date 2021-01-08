#!/bin/sh

HOUR_IN_NL="`TZ=CET date +%H`"
# this is a fallback for misconfigured timezone on the server

# the strooikaart dailySaltUsed is reset at 19:00 CET
# But their data is unreliable (not reset at 19:00 but earlier),
# therefore I'll scrape the seasonalSaltUsed at 23:xx CET
if [ "$HOUR_IN_NL" = "23" ]; then
  echo "Last hour of the day"
else
  echo "Not yet the right hour"
  exit 0
fi

OUTPUT=/output/strooikaart-history.csv

apk add --no-cache curl jq

echo -n "`date +%F`," >> $OUTPUT

curl --silent https://rijkswaterstaatstrooit.nl/api/statistics \
  | jq ".seasonalSaltUsed" \
  >> $OUTPUT

