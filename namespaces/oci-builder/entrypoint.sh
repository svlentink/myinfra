#!/bin/bash
set -ve

INPUT_FILE=/input-list
JOBLIST=/stateful-list-on-host/joblist.txt

if [ ! -s $JOBLIST ]; then
	grep '^--' "$INPUT_FILE" >> "$JOBLIST"
fi
head -1 $JOBLIST > /tmp/next.env
tail --lines=+2 $JOBLIST > /intermediate_file
mv /intermediate_file $JOBLIST
. /tmp/next.env

if [ -z "$CLONE_URL" ]; then
	echo missing CLONE_URL
	cat /tmp/next.env
	exit 1
fi
if [ -z "$IMG_TAG" ]; then
	echo missing IMG_TAG
	cat /tmp/next.env
	exit 1
fi


# https://github.com/GoogleContainerTools/kaniko#pushing-to-docker-hub
CREDENTIALS=`echo -n "$DOCKER_USER:$DOCKER_PASSWORD"|base64`
cat << EOF > /cross-container/.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "$CREDENTIALS"
		}
	}
}
EOF
# https://github.com/GoogleContainerTools/skaffold/issues/3319


cat <<-EOF > /cross-container/.docker/entrypoint
	#!/busybox/sh
	set -ve

	git clone \
		--depth 1 \
		"$CLONE_URL" \
		/workspace
#		--branch "${BRANCH:-main}" \

	cd /workspace

	# Build with VFS storage driver + chroot isolation (no privileged mode needed)
	buildah build \
		--storage-driver vfs \
		--isolation chroot \
		--layers \
		--tag "$IMG_TAG" \
		--file "${DOCKERFILE:-.Dockerfile}" \
		$BUILD_ARGS \
		"${CONTEXT:-.}"
	
	buildah push
		--storage-driver vfs \
		"$IMG_TAG" \
		"docker://$IMG_TAG"

	/kaniko/executor $NEXT
EOF
chmod +x /cross-container/.docker/entrypoint

echo "finished $0"

