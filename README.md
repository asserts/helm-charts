# Asserts Helm Charts

The repository for Asserts Helm Charts packages and code.

## Requirements

* `helm` version >= 3.0 (`brew install helm`)

## Deploying Charts

There is a helm wrapper script in the root of the repository called `deploy-chart.sh` which can
be run with:

```
./deploy-chart.sh -c <chart_name> [-dir <directory>] [-n <namespace>] [-o <override>] [--force] [--debug] [--dry-run]
```

This script will deploy a helm chart and roll back the deployment if unsuccessful by default. Can override with `-f, --force`.

Run `./deploy-chart.sh -h` for a full description of arguments.

### Examples

Deploy chart `model-builder` located in the current working dir to the `asserts` namespace:

```
./deploy-chart.sh -c model-builder -n asserts
```

Deploy chart `assertion-detector` in directory `charts` to namespace `asserts` with `--force` in debug mode:

```
./deploy-chart.sh -c assertion-detector -dir charts -n asserts --force --debug
```

Deploy chart `fluentd` to namespace `monitoring` while providing an override for the `image.tag` value as well
as providing a helm values file to process.
```
./deploy-chart.sh -c fluentd -n monitoring -o "--set image.tag=v1.0" -o "-f myvalues.yaml"
```

## Deleting Charts

```
helm uninstall CHART_NAME
```

or

```
helm delete CHART_NAME
```

`helm uninstall --help` for more options.

## Packaging Charts

First run:

```
helm package CHART_NAME
```

This will generate a .tgz file named `CHART_NAME-VERSION.tgz`.

Next update the index.yaml. This is used to point to the helm package in the remote repository:

```
$ helm repo index .
```

Add the new index and packages to git:

```
$ git add index.yaml CHART_NAME-VERSION.tgz
$ git commit -m MESSAGE
$ git push origin BRANCH
```

## Adding Remote Repos

This shows how to add:

* The Asserts Helm Chart Repository
* Public Repositories

### Asserts Helm Charts Repo

You will need to create a personal github access token by going to https://github.com/settings/tokens
and selecting "Generate new token".

Give it the name `helm-charts` or other identifier you may want to use.

Assign the following permissions:

```
read:org, read:packages, read:repo_hook, read:user, repo, write:packages
```

To add the Asserts Helm Charts repo for your local client, run:

```
$ helm repo add asserts-helm-charts "https://$TOKEN@raw.githubusercontent.com/asserts/helm-charts/master/"
"asserts-helm-charts" has been added to your repositories
```

Test with:

```
$ helm repo list
NAME               	URL
asserts-helm-charts	https://REDACTED-TOKEN@raw.githubusercontent.com/asserts/helm-charts/master/
```

or

```
$ helm search repo asserts
NAME                                  	CHART VERSION	APP VERSION	DESCRIPTION
asserts-helm-charts/assertion-detector	0.2.0        	20.3.0     	Asserts assertion-detector Helm Chart
asserts-helm-charts/metric-generator  	0.2.0        	20.3.0     	A Helm chart for Kubernetes
asserts-helm-charts/model-builder     	0.2.0        	20.3.0     	A Helm chart for Kubernetes
```

### Public Stable Helm Charts Repo

```
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com
"stable" has been added to your repositories
```

```
$ helm repo list
NAME               	URL
stable             	https://kubernetes-charts.storage.googleapis.com/
asserts-helm-charts	https://REDACTED-TOKEN@raw.githubusercontent.com/asserts/helm-charts/master/
```

```
$ helm search repo stable/fluentd
NAME                        	CHART VERSION	APP VERSION	DESCRIPTION
stable/fluentd              	2.4.0        	v2.4.0     	A Fluentd Elasticsearch Helm chart for Kubernetes.
stable/fluentd-elasticsearch	2.0.7        	2.3.2      	DEPRECATED! - A Fluentd Helm chart for Kubernet...
```
