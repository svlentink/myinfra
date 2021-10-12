# Building containers

Since Dockerhub is having the paid option for automated builds,
why not use
[Kaniko](https://github.com/GoogleContainerTools/kaniko)
instead?

## Scheduling

Currently we have a very simple system,
that runs 6 times per days.
Thus this system will only build 42 containers per week.

