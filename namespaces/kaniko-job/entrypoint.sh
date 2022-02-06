#!/bin/bash
set -ve

INPUT_FILE=/tmp/list
JOBLIST=/tmp/joblist
grep '^--' "$INPUT_FILE" > "$JOBLIST"


# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
mkdir -p /kaniko/.docker
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


create_kaniko_entrypoint(){
	if [ -z "$1" ]; then
		echo 'ERROR in script'
		exit 1
	else
		local LINE_TO_EXECUTE="$1"
	fi
	echo "$FUNCNAME $LINE_TO_EXECUTE"
	# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
	# https://github.com/GoogleContainerTools/kaniko/issues/475
	# https://github.com/GoogleContainerTools/kaniko/issues/702
	cat <<-EOF >> /kaniko/.docker/entrypoint
		#!/busybox/sh
		set -ve
		#cat /kaniko/.docker/config.json
		/kaniko/executor $LINE_TO_EXECUTE
	EOF

		#	--verbosity=trace \
		#	--registry-mirror index.docker.io \
		#	--insecure \
		#	--insecure-pull \
		#	--skip-tls-verify \
		#	--skip-tls-verify-pull \
		#	--no-push
  chmod +x /kaniko/.docker/entrypoint
}


if [ -z "$BUILD_ALL" ]; then
	# BUILD_ALL not set, thus we'll only build one
	AMOUNT_RUNS_PER_DAY=7
	CURRENT_HOUR=`date +%H|grep -o '[1-9].*'`
	CURRENT_DAY=`date +%j`
	TOTAL_JOBS=`wc -l $JOBLIST|grep -o '[0-9]*'`
	#TOTAL_JOBS=`grep '^--' $JOBLIST|wc -l`
	
	OFFSET_OF_THE_DAY=$(($AMOUNT_RUNS_PER_DAY * $(($CURRENT_DAY - 1)) ))
	#echo "$AMOUNT_RUNS_PER_DAY, $CURRENT_HOUR, $CURRENT_DAY, $TOTAL_JOBS, $OFFSET_OF_THE_DAY"
	LINE_NUMBER=$(( $(( $(($CURRENT_HOUR + $OFFSET_OF_THE_DAY)) % $TOTAL_JOBS )) + 1 ))
	LINE_TO_EXECUTE=`head -$LINE_NUMBER $JOBLIST| tail -1`
	echo "$LINE_NUMBER: $LINE_TO_EXECUTE"
	
	create_kaniko_entrypoint "$LINE_TO_EXECUTE"
else
	# build all
	# NOTE the following does NOT work due to:
	# https://github.com/GoogleContainerTools/kaniko/issues/1118
	while read LINE_TO_EXECUTE; do
	  create_kaniko_entrypoint "$LINE_TO_EXECUTE --cleanup"
	done < $JOBLIST
fi


echo "finished $0"

