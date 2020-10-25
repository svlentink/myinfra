# My infrastructure

I've shared insights about my infrstructure before,
from my
[data backup strategy](https://blog.lent.ink/post/databackup/)
to my setup using
[docker-compose](https://github.com/svlentink/dockerfiles/tree/master/docker-compose/mywebsite).
This repo. contains my current setup using kubernetes.

At this moment I only run services on port 80, 443, 443 udp and 53 udp.

## Migration procedure

### Server switch

- on old server: stop cert-manager (a day before?) to avoid "Not re-issuing certificate as an attempt has been made in the last hour"
- Creat new server and supply `cloud-init.yml`
- on old server: stop DBs and others that could lead to write err.s
- on old server: `scripts/backup-k8s-pvs.sh`
- on laptop: `scp -3 old-server:/tmp/backup-*.tgz new-server:/tmp/`
- on new server: `cd /;tar xzf /tmp/backup-*.tgz`
- you may want to switch IP here?
- on new server: `cd /srv/git/myinfra/namespaces; ./main.sh apply cdn`

### IP switch

When switching servers and not floating the IP to the new server,
then keep the old server with its IP active for 72+ hours for NS to be propagated.
The actual switch is done in the interface of the DNS registrar.

## FIXME

- explain life cycle management (update cadence)
- explain exit strategy

