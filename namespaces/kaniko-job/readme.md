# Building containers

Since Dockerhub is having the paid option for automated builds,
why not use
[Kaniko](https://github.com/GoogleContainerTools/kaniko)
instead?

## Scheduling

Currently we have a very simple system,
that runs 6 times per days.
Thus this system will only build 42 containers per week.

## secret creation

Please use `docker login`
instead of what the
[docs](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#log-in-to-docker)
say, since it the `base64` method might
[fail](https://github.com/GoogleContainerTools/kaniko/issues/1209#issuecomment-944903966)
you.

