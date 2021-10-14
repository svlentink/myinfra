#!/bin/bash
set -ve

JOBLIST=/tmp/list
AMOUNT_RUNS_PER_DAY=6
CURRENT_HOUR=`date +%H`
CURRENT_DAY=`date +%j`
TOTAL_JOBS=`wc -l $JOBLIST|grep -o [0-9]*`

# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
#mkdir -p /kaniko/.docker
CREDENTIALS=`echo $DOCKER_USER:$DOCKER_PASSWORD|base64`
cat << EOF > /kaniko/.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "$CREDENTIALS",
			"username": "$DOCKER_USER",
			"password": "$DOCKER_PASSWORD",
			"email": "$DOCKER_EMAIL"
		}
	},
	"experimental" : "disabled",
	"HttpHeaders" : {
		"User-Agent" : "Docker-Client/19.03.4 (darwin)"
	}
}
EOF
# https://github.com/GoogleContainerTools/skaffold/issues/3319

OFFSET_OF_THE_DAY=$(($AMOUNT_RUNS_PER_DAY * $(($CURRENT_DAY - 1)) ))
#echo "$AMOUNT_RUNS_PER_DAY, $CURRENT_HOUR, $CURRENT_DAY, $TOTAL_JOBS, $OFFSET_OF_THE_DAY"
LINE_NUMBER=$(( $(( $(($CURRENT_HOUR + $OFFSET_OF_THE_DAY)) % $TOTAL_JOBS )) + 1 ))
LINE_TO_EXECUTE=`head -$LINE_NUMBER $JOBLIST| tail -1`
echo "$LINE_NUMBER: $LINE_TO_EXECUTE"
if [[ -z "$LINE_TO_EXECUTE" ]]; then
	echo Whoops an empty line
	exit 1
fi

# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
# https://github.com/GoogleContainerTools/kaniko/issues/475
cat << EOF > /kaniko/.docker/entrypoint
#!/busybox/sh
cat /kaniko/.docker/config.json
/kaniko/executor $LINE_TO_EXECUTE
EOF
chmod +x /kaniko/.docker/entrypoint

exit 0
cat /kaniko/.docker/entrypoint
cat /kaniko/.docker/config.json # WARNING exposes password to logs
echo "finished $0"

