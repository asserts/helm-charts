# AWS AutoScalingGroup Activity Exporter

[AWS AutoScalingGroupActivity Exporter](https://github.com/asserts/aws-autoscalinggroup-activity-exporter) is a A Prometheus exporter for converting
AWS AutoScalingGroup Actvities to metrics.


## Get Repo Info

```console
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
```

## Configuration and Installation

See [AWS AutoScalingGroupActivity Exporter Configuration](https://github.com/asserts/aws-autoscalinggroup-activity-exporter#configuration) for software configuration beyond
the following example.

The two main values that need to be set are the `region` and the `config`. Note that without
`.Values.config` -> tags being set, ALL AutoScalingGroups in the region will be discovered.


Ex: Running in AWS Region `us-west-2` while only looking at AutoScalingGroups with tag: `env=dev` while detecting user_requests, rebalances, and spot instance interruptions.

using values file `dev-values.yaml`:

```console
region: us-west-2
config: |
  # autoscaling groups to discover by tag
  tags:
    - key: "env"
      value: "dev"
  causes:
    - pattern: ".*Spot Instance interruption notice.*"
      reason: "interrupt"
    - pattern: ".*EC2 instance rebalance recommendation.*"
      reason: "rebalance"
    - pattern: ".*user request.*"
      reason: "user_request"
```

Run:

```console
helm upgrade --install [RELEASE_NAME] asserts/aws-autoscalinggroup-activity-exporter -f dev-vaules.yaml
```

To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values asserts/aws-autoscalinggroup-activity-exporter
```