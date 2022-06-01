#!/bin/bash
set -ve

INPUT_FILE=/tmp/list
JOBLIST=/tmp/joblist
grep '^--' "$INPUT_FILE" > "$JOBLIST"


# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
mkdir -p /kaniko/.docker/buildjobs
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


# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
# https://github.com/GoogleContainerTools/kaniko/issues/475
# https://github.com/GoogleContainerTools/kaniko/issues/702
cat <<-'EOF' > /kaniko/.docker/entrypoint
	#!/busybox/sh
	set -ve
	#cat /kaniko/.docker/config.json
	NEXT="/kaniko/.docker/buildjobs/"$(ls /kaniko/.docker/buildjobs|head -1)
	if [ -z "$NEXT" ]; then
		echo No more buildjobs
		exit 0
	fi
	(
		/kaniko/executor $(cat $NEXT)
		#	--verbosity=trace \
		#	--registry-mirror index.docker.io \
		#	--insecure \
		#	--insecure-pull \
		#	--skip-tls-verify \
		#	--skip-tls-verify-pull \
		#	--no-push
	) || true
	rm "$NEXT"
	kill 1

EOF
chmod +x /kaniko/.docker/entrypoint


create_build_job(){
	if [ -z "$1" ]; then
		echo 'ERROR in script'
		exit 1
	else
		local LINE_TO_EXECUTE="$1"
	fi
	echo "$FUNCNAME $LINE_TO_EXECUTE"
	FILE_NAME=`echo "$LINE_TO_EXECUTE"|md5sum|cut -c1-32`
	echo "$LINE_TO_EXECUTE" > /kaniko/.docker/buildjobs/$FILE_NAME
}


if [ -z "$BUILD_ALL" ]; then
	# BUILD_ALL not set, thus we'll only build one
	AMOUNT_RUNS_PER_DAY=7
	CURRENT_HOUR=`date +%H|grep -o '[1-9].*'`
	CURRENT_DAY=`date +%j|grep -o '[1-9][0-9]*'`
	TOTAL_JOBS=`wc -l $JOBLIST|grep -o '[0-9]*'`
	#TOTAL_JOBS=`grep '^--' $JOBLIST|wc -l`
	
	OFFSET_OF_THE_DAY=$(($AMOUNT_RUNS_PER_DAY * $(($CURRENT_DAY - 1)) ))
	#echo "$AMOUNT_RUNS_PER_DAY, $CURRENT_HOUR, $CURRENT_DAY, $TOTAL_JOBS, $OFFSET_OF_THE_DAY"
	LINE_NUMBER=$(( $(( $(($CURRENT_HOUR + $OFFSET_OF_THE_DAY)) % $TOTAL_JOBS )) + 1 ))
	LINE_TO_EXECUTE=`head -$LINE_NUMBER $JOBLIST| tail -1`
	echo "$LINE_NUMBER: $LINE_TO_EXECUTE"
	
	create_build_job "$LINE_TO_EXECUTE"
else
	# build all
	# Since there is a bug in Kaniko:
	# https://github.com/GoogleContainerTools/kaniko/issues/1118
	# we let the pod fail as many times as we have builds,
	# to be able to loop over all
	while read LINE_TO_EXECUTE; do
	  create_build_job "$LINE_TO_EXECUTE" # --cleanup" # cleanup does not do what is promises
	done < $JOBLIST
fi


echo "finished $0"

