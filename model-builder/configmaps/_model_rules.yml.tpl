# managed by Helm
version: 1.0
entities:
  - type: "Service"
    definedBy:
      pattern: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
      labelForName: "service"
      properties:
  - type: "Jvm"
    definedBy:
      pattern: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
      labelForName: "instance"
      properties:
        pod: "pod"
        service: "service"
  - type: "ServiceEndPoint"
    definedBy:
      pattern: "{__name__=\"jvm_gc_pause_seconds_count\",namespace=\"petclinic\"}"
      labelForName: "endpoint"
      properties:
        service: "service"
  - type: "Container"
    definedBy:
      pattern: "{__name__=\"container_cpu_cfs_periods_total\",namespace=\"petclinic\",container!=\"POD\"}"
      labelForName: "container"
      properties:
        pod: "pod"
        host: "instance"
  - type: "Node"
    definedBy:
      pattern: "{__name__=\"node_cpu_seconds_total\",namespace=\"petclinic\"}"
      labelForName: "instance"
      properties:
# Redis service for standalone & cluster
  - type: "RedisService"
    definedBy:
      pattern: "label_join(redis_instance_info, \"asserts_group\", \":\", \"namespace\", \"service\")"
      labelForName: "asserts_group"
      properties:
        service: "service"
        redis_mode: "redis_mode"
        asserts_group: "asserts_group"
  - type: "RedisInstance"
    definedBy:
      pattern: "label_join(redis_instance_info, \"asserts_group\", \":\", \"namespace\", \"service\")"
      labelForName: "pod"
      properties:
        role: "role"
        redis_mode: "redis_mode"
        asserts_group: "asserts_group"

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
  - type: CONTAINS
    startEntityType: RedisService
    endEntityType: RedisInstance
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: asserts_group
      endPropertyLabel: asserts_group
