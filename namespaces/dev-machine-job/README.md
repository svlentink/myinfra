# Dev env.

Automatically spin up a dev machine during working hours.

The `.env` file should contain
[3 variables](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs#arguments-reference)
for Scaleway
and `CALENDAR_URL=` pointing to
[Secret address in iCal format](https://calendar.google.com/calendar/u/0/r/settings/calendar).

## Testing it

First
[manually create](https://console.scaleway.com/instance/volumes/create)
a
[b\_ssd](https://developers.scaleway.com/en/products/instance/api/#volumes-7e8a39)
volume with the `name` mentioned in `main.tf`.

Testing:
```
kubectl create job testjob --from=cronjob/start-dev-env -n dev-machine-job
kubectl describe job -n dev-machine-job testjob|tail
kubectl delete job -n dev-machine-job testjob
```

The machine is ready in around 5min:
```
# On Kubernetes
kubectl describe pod -n dev-machine-job start-dev-env-1598176800-czsrw|grep -A 3 Completed
      Reason:       Completed
      Exit Code:    0
      Started:      Sun, 23 Aug 2020 17:36:54 +0200
      Finished:     Sun, 23 Aug 2020 17:37:40 +0200

# On the newly created dev machine
cloud-init analyze show | grep Total\ Time
      Total Time: 139.31600 seconds
```
