# OCI builder

There are two options, buildkit and buildah.
Buildkit requires a daemon and is more efficient for a container build server that builds lots of containers all the time.
However, buildah is simpler and doesn't need a daemon and won't have lingering resources after it's done.

So
[buildah](https://dev.to/jonny2k26/kaniko-is-dead-heres-how-i-build-tenant-images-in-kubernetes-now-4em8)
it is for my private/hobby projects.

