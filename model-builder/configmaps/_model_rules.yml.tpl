# managed by Helm
version: 1.0
entities:
  # Service from service label
  - type: "Service"
    definedBy:
      pattern: "count by (namespace, job) (up)"
      labelsForName: ["namespace", "job"]
      properties:
        namespace: "namespace"
        service: "job"
  # Jvm from springboot
  - type: "Jvm"
    definedBy:
      pattern: "{__name__=\"jvm_gc_live_data_size_bytes\"}"
      labelsForName: ["instance"]
      properties:
        namespace: "namespace"
        instance: "instance"
        service: ["namespace", "job"]
  # Node from Springboot
  - type: "Node"
    definedBy:
      pattern: "{__name__=\"jvm_gc_live_data_size_bytes\"}"
      labelsForName: ["instance"]
      properties:
        namespace: "namespace"
  # Node from node exporter
  - type: "Node"
    definedBy:
      pattern: "{__name__=\"node_cpu_seconds_total\"}"
      labelsForName: ["instance"]
      properties:
        namespace: "namespace"
  # Redis service for standalone & cluster
  - type: "RedisService"
    definedBy:
      pattern: "{__name__=\"redis_instance_info\"}"
      labelsForName: ["namespace", "service"]
      properties:
        namespace: "namespace"
        redis_mode: "redis_mode"
  - type: "RedisInstance"
    definedBy:
      pattern: "{__name__=\"redis_instance_info\"}"
      labelsForName: ["pod"]
      properties:
        namespace: "namespace"
        role: "role"
        redis_mode: "redis_mode"
        service: ["namespace", "service"]

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
    endEntityType: Jvm
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: instance
  - type: RUNS_ON
    startEntityType: Service
    endEntityType: Jvm
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
      startPropertyLabel: name
      endPropertyLabel: service

