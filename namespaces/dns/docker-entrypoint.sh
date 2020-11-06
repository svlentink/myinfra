#!/bin/sh
set -e

ZONEFILESDIR=/var/processedzones
cp -a /zones $ZONEFILESDIR
ls -l $ZONEFILESDIR

# The following allows us to have
# environment variables that start with
# IP.. like IPV4_EXAMPLECOM=10.10.10.10
# which allows us to have IPs defined
# in our envs
for i in `printenv|grep ^IP`; do
  echo "Setting $i"
  ESCAPED=`echo $i | sed 's/\./\\\\./g'`
  sed -i "s=$ESCAPED\ \;=" $ZONEFILESDIR/*.conf
done

echo "=== BEGIN zone files ==="
cat $ZONEFILESDIR/*.conf
echo "=== END zone files ==="

cat << EOF > /etc/named.conf
//Authoritative dns
options {
  directory "$ZONEFILESDIR";
//  key-directory "/keys";
  recursion no;
  dnssec-enable no;
  dnssec-validation auto;
};
EOF

for f in $ZONEFILESDIR/*; do
  ZONEFILE=`basename $f`
  ZONENAME=`echo $ZONEFILE|sed 's/\.conf$//'`
cat << EOF >> /etc/named.conf
zone "$ZONENAME" {
  file "$ZONEFILE";
  type master;
  notify no;
};
EOF
done

echo "=== BEGIN named conf ==="
cat /etc/named.conf
echo "=== END named conf ==="

apk --no-cache add bind

named -c /etc/named.conf -g -u root #named
