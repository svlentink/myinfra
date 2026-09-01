#!/bin/bash
set -ve

INPUT_FILE=/input-list
JOBLIST=/stateful-list-on-host/joblist.txt

if [ ! -s $JOBLIST ]; then
	grep '^CLONE_URL' "$INPUT_FILE" >> "$JOBLIST"
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
mkdir -p /cross-container/.docker
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

echo "Cloning: ${CLONE_URL}"
command -v git || (apt update && apt install -y git)
git clone \
	--depth 1 \
	"$CLONE_URL" \
	/cross-container/workspace
#	--branch "${BRANCH:-main}"
cat /cross-container/workspace/.git/config

cat <<-EOF > /cross-container/.docker/entrypoint
	#!/bin/sh
	set -ve

	cd /cross-container/workspace
	mkdir -p ~/.docker
	cp /cross-container/.docker/config.json ~/.docker/config.json

	# Build with VFS storage driver + chroot isolation (no privileged mode needed)
	BUILDAH_CONF='--storage-driver vfs'
	BUILDAH_CONF='--storage-driver overlay'
	buildah \$BUILDAH_CONF build \
		--isolation chroot \
		--tag "$IMG_TAG" \
		--file "${DOCKERFILE:-./Dockerfile}" \
		$BUILD_ARGS \
		"${CONTEXT:-.}"
#		--layers \
	
	buildah \$BUILDAH_CONF push \
		"$IMG_TAG"
EOF
chmod +x /cross-container/.docker/entrypoint

echo "finished $0"

