# managed by Helm
---
version: 1.0
entities:
  - type: Node
    definedBy:
      pattern: "kube_node_info"
      labelsForName: ["node"]
      properties:
        kernel: "kernel_version"
        os: "os_image"
        provider_id: "provider_id" # e.g. aws:///us-west-2a/i-0d172102720f5cfe4

  - type: Pod
    definedBy:
      pattern: "kube_pod_info and on(pod) up"
      labelsForName: ["pod"]
      properties:
        node: "node"
        namespace: "namespace"
        node_ip: "host_ip"
        pod_ip: "pod_ip"
        kind: "created_by_kind" # Values are : DaemonSet | ReplicaSet | StatefulSet

  # Update Node with IP which may be useful
  - type: Node
    definedBy:
      pattern: "sum by (host_ip, node) (kube_pod_info)"
      labelsForName: ["node"]
      properties:
        ip: "host_ip"

  - type: Container
    definedBy:
      pattern: "kube_pod_container_info and on(pod) up"
      labelsForName: ["container"]
      properties:
        pod: "pod"
        namespace: "namespace"

  # Labeling it K8 since we may have other Services
  - type: K8Service
    definedBy:
      pattern: "kube_service_info and on(service) up"
      labelsForName: ["service"]
      properties:
        namespace: "namespace"

  - type: Ingress
    definedBy:
      pattern: "kube_ingress_path"
      labelsForName: ["ingress", "path"]
      properties:
        ingress: "ingress"
        dns: "host"
        path: "path"
        service: "service_name"
        namespace: "namespace"

  # Prom Exporters
  - type: Job
    definedBy:
      pattern: "sum by (job, namespace, service) (up)"
      labelsForName: ["job"]
      properties:
        namespace: "namespace"
        service: "service"


  # Instance from 'up' metric
  # pod, service, namespace will be available only in K8
  - type: Instance
    definedBy:
      pattern: "up"
      labelsForName: ["job", "instance"]
      properties:
        job: "job"
        instance: "instance"
        pod: "pod"
        node: "node"
        service: "service"
        namespace: "namespace"

  # Runtime Info .
  # TBD : Should we move introduced enumerated runtime ? e.g. java | go | ruby
  #       If we do, How do we handle Open JDK vs Oracle JDK et al.

  # JVM
  - type: Instance
    definedBy:
      pattern: "jvm_info"
      labelsForName: ["job", "instance"]
      properties:
        runtime: "runtime"
        vendor: "vendor"
        version: "version"

  # Go Runtime Info,
  - type: Instance
    definedBy:
      pattern: "go_info"
      labelsForName: ["job", "instance"]
      properties:
        version: "version"


  # Instance -> Redis Role (master|slave), Mode (cluster|standalone), version
  #
  # NOTE ::
  # An exporter can scrape multiple redis instances,
  # that may span cluster and standalone redis nodes.
  # Hence a Job can't be reliably labeled as Redis : Cluster | StandAlone
  - type: Instance
    definedBy:
      pattern: "redis_instance_info"
      labelsForName: ["job", "instance"]
      properties:
        redis_mode: "redis_mode"
        redis_role: "role"
        redis_version: "redis_version"

   ### KAFKA RULES TO BE RE-INTRODUCED ###

################################
#                     .__          __  .__
#  _______   ____ |  | _____ _/  |_|__| ____   ____   ______
#  \_  __ \_/ __ \|  | \__  \\   __\  |/  _ \ /    \ /  ___/
#  |  | \/\  ___/|  |__/ __ \|  | |  (  <_> )   |  \\___ \
#  |__|    \___  >____(____  /__| |__|\____/|___|  /____  >
#  \/          \/                    \/     \/
################################

relations:
  # Pod -> Node
  - type: RUNS_ON
    startEntityType: Pod
    endEntityType: Node
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: node
      endPropertyLabel: name

  # Container -> Pod
  - type: RUNS_ON
    startEntityType: Container
    endEntityType: Pod
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: pod
      endPropertyLabel: name

  # Instance -> Pod
  - type: RUNS_ON
    startEntityType: Instance
    endEntityType: Pod
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: pod
      endPropertyLabel: name

  # Instance -> Node for cAdvisor and kubelet running on node
  - type: RUNS_ON
    startEntityType: Instance
    endEntityType: Node
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: node
      endPropertyLabel: name

  # Job -> Instance
  - type: COLLECTION_OF
    startEntityType: Job
    endEntityType: Instance
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: job

  # Ingress -> Service
  - type: ROUTES_TO
    startEntityType: Ingress
    endEntityType: K8Service
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: service
      endPropertyLabel: name

  # K8Service -> Job
  - type: ROUTES_TO
    startEntityType: K8Service
    endEntityType: Job
    definedBy:
      source: ENTITY_MATCH
      matchOp: EQUALS
      startPropertyLabel: name
      endPropertyLabel: service

  ### SERVICE MESH ROUTING RELATIONS ###

  # Spring Boot Gateway
  - type: CALLS
    startEntityType: Job
    endEntityType: Job
    definedBy:
      source: METRICS
      pattern: "gateway_requests_seconds_sum"
      startEntityNameLabels: ["namespace", "endpoint"]
      endEntityNameLabels: ["namespace", "routeId"]

  # Spring Boot Netflix Hystrix
  - type: CALLS
    startEntityType: Job
    endEntityType: Job
    definedBy:
      source: METRICS
      pattern: "hystrix_execution_total"
      startEntityNameLabels: ["namespace", "service"]
      endEntityNameLabels: ["namespace", "key"]

############################# OLD RULES #############################
#  # Service from service label
#  - type: "Service"
#    definedBy:
#      pattern: "min by (namespace, service) (up) > 0"
#      labelsForName: ["namespace", "service"]
#      properties:
#        namespace: "namespace"
#        service: "service"
#
#  # Jvm from springboot
#  - type: "Jvm"
#    definedBy:
#      pattern: "{__name__=\"jvm_gc_live_data_size_bytes\"}"
#      labelsForName: ["instance"]
#      properties:
#        namespace: "namespace"
#        instance: "instance"
#        service: ["namespace", "service"]
#
#  # Node from Springboot
#  - type: "Node"
#    definedBy:
#      pattern: "{__name__=\"jvm_gc_live_data_size_bytes\"}"
#      labelsForName: ["instance"]
#      properties:
#        namespace: "namespace"
#
#  # Node from node exporter
#  - type: "Node"
#    definedBy:
#      pattern: "{__name__=\"node_cpu_seconds_total\"}"
#      labelsForName: ["instance"]
#      properties:
#        namespace: "namespace"
#
#  # Redis service for standalone & cluster
#  - type: "RedisService"
#    definedBy:
#      pattern: "{__name__=\"redis_instance_info\"}"
#      labelsForName: ["namespace", "service"]
#      properties:
#        namespace: "namespace"
#        redis_mode: "redis_mode"
#  - type: "RedisInstance"
#    definedBy:
#      pattern: "{__name__=\"redis_instance_info\"}"
#      labelsForName: ["pod"]
#      properties:
#        namespace: "namespace"
#        role: "role"
#        redis_mode: "redis_mode"
#        service: ["namespace", "service"]
#
#  # Kafka JMX
#  - type: "KafkaBroker"
#    definedBy:
#      pattern: "{__name__=\"kafka_server_kafkaserver_brokerstate\"}"
#      labelsForName: ["instance"]
#  - type: "KafkaTopic"
#    definedBy:
#      pattern: "{__name__=\"kafka_server_brokertopicmetrics_messagesin_total\", topic!=\"\"}"
#      labelsForName: ["topic"]
#  # Kafka Exporter. It only provides topic, partition and broker count, but no broker information
#  - type: "KafkaTopic"
#    definedBy:
#      pattern: "{__name__=\"kafka_topic_partitions\", topic!=\"\"}"
#      labelsForName: ["topic"]
#
#  # Nginx
#  - type: "NginxIngressController"
#    definedBy:
#      pattern: "{__name__=\"nginx_ingress_controller_leader_election_status\"}"
#      labelsForName: ["controller_class"]
#  - type: "NginxIngress"
#    definedBy:
#      pattern: "avg by(controller_class, ingress) (nginx_ingress_controller_requests{exported_service!=\"\"})"
#      labelsForName: ["ingress"]
#      properties:
#        controller_class: "controller_class"
#relations:
#  - type: CALLS
#    startEntityType: Service
#    endEntityType: Service
#    definedBy:
#      source: METRICS
#      pattern: "{__name__=\"gateway_requests_seconds_sum\"}"
#      startEntityNameLabels: ["namespace", "endpoint"]
#      endEntityNameLabels: ["namespace", "routeId"]
#  - type: CALLS
#    startEntityType: Service
#    endEntityType: Service
#    definedBy:
#      source: METRICS
#      pattern: "{__name__=\"hystrix_execution_total\"}"
#      startEntityNameLabels: ["namespace", "service"]
#      endEntityNameLabels: ["namespace", "key"]
#  - type: HOSTS
#    startEntityType: Node
#    endEntityType: Jvm
#    definedBy:
#      source: ENTITY_MATCH
#      matchOp: EQUALS
#      startPropertyLabel: name
#      endPropertyLabel: instance
#  - type: RUNS_ON
#    startEntityType: Service
#    endEntityType: Jvm
#    definedBy:
#      source: ENTITY_MATCH
#      matchOp: EQUALS
#      startPropertyLabel: name
#      endPropertyLabel: service
#  - type: CONTAINS
#    startEntityType: RedisService
#    endEntityType: RedisInstance
#    definedBy:
#      source: ENTITY_MATCH
#      matchOp: EQUALS
#      startPropertyLabel: name
#      endPropertyLabel: service
#  - type: HOSTS
#    startEntityType: KafkaBroker
#    endEntityType: KafkaTopic
#    definedBy:
#      source: METRICS
#      pattern: "{__name__=\"kafka_server_brokertopicmetrics_messagesin_total\", topic!=\"\"}"
#      startEntityNameLabels: ["instance"]
#      endEntityNameLabels: ["topic"]
#  - type: HAS_INGRESS
#    startEntityType: NginxIngressController
#    endEntityType: NginxIngress
#    definedBy:
#      source: ENTITY_MATCH
#      matchOp: EQUALS
#      startPropertyLabel: name
#      endPropertyLabel: controller_class
#  - type: ROUTES_TO
#    startEntityType: NginxIngress
#    endEntityType: Service
#    definedBy:
#      source: METRICS
#      pattern: "avg by(controller_class, exported_namespace, exported_service, ingress) (nginx_ingress_controller_requests{exported_service!=\"\"})"
#      startEntityNameLabels: ["ingress"]
#      endEntityNameLabels: ["exported_namespace", "exported_service"]
