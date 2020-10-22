# My infrastructure

I've shared insights about my infrstructure before,
from my
[data backup strategy](https://blog.lent.ink/post/databackup/)
to my setup using
[docker-compose](https://github.com/svlentink/dockerfiles/tree/master/docker-compose/mywebsite).
This repo. contains my current setup using kubernetes.

At this moment I only run services on port 80, 443, 443 udp and 53 udp.


## Mounted directories

<!--
~/.ssh keys
-->

```shell
for f in `find . -name '*.yml'`;do grep 'path: /' $f|grep -v '\- path' && echo $f; done
```

## FIXME

- explain life cycle management (update cadence)
- explain exit strategy

