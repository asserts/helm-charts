# Asserts

[Asserts](http://www.asserts.ai) is a metrics intelligence platform built on Prometheus’s open ecosystem. Asserts scans your metrics to build a dependency graph and then analyzes them using Asserts's [SAAFE](https://docs.asserts.ai/understanding-saafe-model) model.

## Introduction

This chart bootstraps an [Asserts](https://www.asserts.ai) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.17+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- A Prometheus compatible endpoint to query
- [kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) (metrics from the Prometheus endpoint)
- [node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter) (metrics from the Prometheus endpoint)

## Installing the Chart

Please have a look at the 3 options below and decide which one matches your use case
before proceeding with one of them.

### You ARE running Prometheus-Operator in the same cluster you are installing Asserts

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm upgrade --install asserts asserts/asserts -n asserts --create-namespace
```

> **Note:** In order for your Prometheus-Operator's Prometheus to pickup the Asserts ServiceMonitor
you need to ensure that the `serviceMonitorSelector` for your Prometheus is added to the Asserts
ServiceMonitor's extraLabels. Use the following steps to verify the Asserts ServiceMonitor will be
picked up by your Prometheus.

Check your Prometheus's `serviceMonitorSelector`:

```
kubectl get prometheus -n <namespace-of-your-prometheus> -ojsonpath='{.items[].spec.serviceMonitorSelector}'
```

Ex Output:

```
{"matchLabels":{"release":"kube-prometheus-stack"}}
```

This requires you to add the following to a values file:

```
serviceMonitor:
  extraLabels:
    release: kube-prometheus-stack
```

### You ARE running VANILLA Prometheus in the same cluster Asserts is being installed

This assumes you are using annotation based [kubernetes service discovery](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config) in your Prometheus configuration such as used in the official [Prometheus Helm Chart default scrape config](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml#L771). This means that the annotation `prometheus.io/scrape: "true"` will let your Prometheus know to scrape Asserts services.

Create a values file with the following, here we will call it `values.yaml`:

```yaml
# Set since not running Prometheus-Operator (default is true)
serviceMonitor:
  enabled: false
```

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm upgrade --install asserts asserts/asserts -n asserts -f values.yaml --create-namespace
```

### You ARE NOT running Prometheus/Prometheus-Operator in the same cluster where Asserts is being installed (test or management cluster).

Create a values file with the following, here we will call it `values.yaml`:

```yaml
## When this is set to true, the Asserts Tsdb will scrape
## all of the Asserts Services.
selfScrape: true

## Set since not running Prometheus-Operator (default is true)
serviceMonitor:
  enabled: false
```

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm upgrade --install asserts asserts/asserts -n asserts -f values.yaml --create-namespace
```


## Verify and Access

When Asserts is spinning up for the first time, it usually takes about 3-4 minutes
but could take longer depending on the hardware resources allocated (e.g. a kind/k3d cluster).

Once all containers are initialized and running:

```bash
kubectl get pods -l app.kubernetes.io/instance=asserts -n asserts
```

You can then login to the asserts-ui by running:

```bash
kubectl port-forward svc/asserts-ui 8080 -n asserts
```

And opening your browser to [http://localhost:8080](http://localhost:8080)
you will be directed to the Asserts Registration page. There you can acquire
a license as seen [here](https://docs.asserts.ai/getting-started/self-hosted/helm-chart#see-the-data)

## Configuring Promethueus DataSources

Configure your Prometheus DataSource which Asserts will connect to
and query by following [these instructions](https://docs.asserts.ai/integrations/data-source/prometheus)

## Uninstalling the Chart

To uninstall/delete the `asserts` deployment:

```console
helm delete asserts -n asserts
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

To delete the PVC's associated with `asserts`:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=asserts -n asserts
```

> **Note**: Deleting the PVC's will delete all asserts related data as well.
