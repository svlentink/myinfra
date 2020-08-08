# Dev env.

Automatically spin up a dev machine during working hours.

The `.env` file should contain
[3 variables](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs#arguments-reference).

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

