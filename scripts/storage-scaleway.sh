#!/bin/bash

#https://www.scaleway.com/en/docs/object-storage-with-s3cmd/


which s3cmd >/dev/null || apt install -y s3cmd

. ../namespaces/dev-machine-job/.env

cat << EOF > ~/.s3cfg
[default]

#host_base = s3.nl-ams.scw.cloud
#host_bucket = %(bucket)s.s3.nl-ams.scw.cloud
#bucket_location = nl-ams

bucket_location = fr-par
host_base = s3.fr-par.scw.cloud
host_bucket = s3.fr-par.scw.cloud

use_https = True

access_key = $SCW_ACCESS_KEY
secret_key = $SCW_SECRET_KEY
EOF

echo "mb (make bucket)"
s3cmd mb "s3://sander"


