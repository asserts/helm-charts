# managed by Helm
version: 1.0
entities:
  - when: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
    create:
      type: "Service"
      properties:
        name: "service"
  - when: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
    create:
      type: "Jvm"
      properties:
        name: "instance"
        pod: "pod"
        service: "service"
  - when: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
    create:
      type: "ServiceEndPoint"
      properties:
        name: "endpoint"
        service: "service"
  - when: "{__name__=\"container_cpu_cfs_periods_total\",namespace=\"petclinic\",container!=\"POD\"}"
    create:
      type: "Container"
      properties:
        name: "container"
        pod: "pod"
        host: "instance"
  - when: "{__name__=\"node_cpu_seconds_total\",namespace=\"petclinic\"}"
    create:
      type: "Node"
      properties:
        name: "instance"
relations:
  - type: CALLS
    startEntityType: Service
    endEntityType: Service
    definedBy:
      source: METRICS
      pattern: "{__name__=\"gateway_requests_seconds_sum\"}"
      startEntityNameLabel: endpoint
      endEntityNameLabel: routeId
  - type: CALLS
    startEntityType: Service
    endEntityType: Service
    definedBy:
      source: METRICS
      pattern: "{__name__=\"hystrix_execution_total\"}"
      startEntityNameLabel: "service"
      endEntityNameLabel: "key"
  - type: HOSTS
    startEntityType: Node
    endEntityType: Container
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: host
  - type: RUNS_ON
    startEntityType: Service
    endEntityType: Jvm
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: service
  - type: HAS_SEP
    startEntityType: Service
    endEntityType: ServiceEndPoint
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: service

