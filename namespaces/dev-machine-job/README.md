# Dev env.

Automatically spin up a dev machine during working hours.

The `.env` file should contain
[3 variables](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs#arguments-reference).

## Testing it

First you need to manually create the a
[volume](https://console.scaleway.com/instance/volumes/create)
as with the name mentioned in `main.tf`.

Testing:
```
kubectl create job testjob --from=cronjob/start-dev-env -n dev-machine-job
kubectl describe job -n dev-machine-job testjob|tail
kubectl delete job -n dev-machine-job testjob
```

