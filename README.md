# My infrastructure

I've shared insights about my infrstructure before,
from my
[data backup strategy](https://blog.lent.ink/post/databackup/)
to my setup using
[docker-compose](https://github.com/svlentink/dockerfiles/tree/master/docker-compose/mywebsite).
This repo. contains my current setup using kubernetes.

At this moment I only run services on port 80, 443, 443 udp and 53 udp.

<!--
## Directories I've used in the past

- ~/.sekretoj
- ~/Dropbox
- wordpress
- ~/.ssh keys
- systemd (wordpress-backup, deploy-containers)

-->

## FIXME

- explain life cycle management (update cadence)
- explain exit strategy

```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.yaml
```

