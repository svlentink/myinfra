#!/bin/bash
set -ve

INPUT_FILE=/input-list
JOBLIST=/stateful-list-on-host/joblist.txt

if [ ! -s $JOBLIST ]; then
	grep '^--' "$INPUT_FILE" >> "$JOBLIST"
fi
NEXT=`head -1 $JOBLIST`
tail --lines=+2 $JOBLIST > /intermediate_file
mv /intermediate_file $JOBLIST


# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
CREDENTIALS=`echo -n "$DOCKER_USER:$DOCKER_PASSWORD"|base64`
cat << EOF > /kaniko/.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "$CREDENTIALS"
		}
	}
}
EOF
# https://github.com/GoogleContainerTools/skaffold/issues/3319


cat <<-EOF > /kaniko/.docker/entrypoint
	#!/busybox/sh
	set -ve
	/kaniko/executor $NEXT
EOF
chmod +x /kaniko/.docker/entrypoint

echo "finished $0"

