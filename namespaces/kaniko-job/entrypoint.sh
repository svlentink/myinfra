#!/bin/bash

JOBLIST=/tmp/list
AMOUNT_RUNS_PER_DAY=6
CURRENT_HOUR=`date +%H`
CURRENT_DAY=`date +%j`
#TOTAL_JOBS=`wc -l $JOBLIST`

# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
CREDENTIALS=`echo $DOCKER_USER:$DOCKER_PASSWORD|base64`
cat << EOF > /kaniko/.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "$CREDENTIALS"
		}
	}
}
EOF

OFFSET_OF_THE_DAY=$(($AMOUNT_RUNS_PER_DAY * $(($CURRENT_DAY - 1)) ))
LINE_NUMBER=$(( $(($CURRENT_HOUR + $OFFSET_OF_THE_DAY)) % $TOTAL_JOBS ))
LINE_TO_EXECUTE=`head -$LINE_NUMBER | tail -1`
if [[ -z "$LINE_TO_EXECUTE" ]]; then
	echo Whoops an empty line
	exit
fi

# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
/kaniko/executor $LINE_TO_EXECUTE

