#!/bin/bash
set -ve

if [ -f /tmp/kaniko/entrypoint ]; then
	cp /tmp/kaniko/entrypoint /kaniko/.docker/entrypoint
	echo Entrypoint already there stopping for faster debugging
	exit 0
fi

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
			"auth": "$CREDENTIALS"
		}
	}
}
EOF

OFFSET_OF_THE_DAY=$(($AMOUNT_RUNS_PER_DAY * $(($CURRENT_DAY - 1)) ))
echo "$AMOUNT_RUNS_PER_DAY, $CURRENT_HOUR, $CURRENT_DAY, $TOTAL_JOBS, $OFFSET_OF_THE_DAY"
LINE_NUMBER=$(( $(( $(($CURRENT_HOUR + $OFFSET_OF_THE_DAY)) % $TOTAL_JOBS )) + 1 ))
LINE_TO_EXECUTE=`head -$LINE_NUMBER $JOBLIST| tail -1`
echo "$LINE_NUMBER: $LINE_TO_EXECUTE"
if [[ -z "$LINE_TO_EXECUTE" ]]; then
	echo Whoops an empty line
	exit 1
fi

# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
cat << EOF > /tmp/script
#!/bin/sh
/kaniko/executor $LINE_TO_EXECUTE
EOF
chmod +x /tmp/script
which shc || (apt update; apt install -y shc gcc)
shc -r -U -f /tmp/script -o /kaniko/.docker/entrypoint
cp /kaniko/.docker/entrypoint /tmp/kaniko/entrypoint

echo "finished $0"

