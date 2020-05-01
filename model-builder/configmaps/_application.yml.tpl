# managed by Helm
rules:
  path: "file:///opt/asserts/model-builder/conf/model_rules/**/*.yml"

server:
  port: 8060
  servlet:
    context-path: "/model-builder"

# enable Prometheus metrics
management:
  endpoint:
    prometheus:
      enabled: true
    info:
      enabled: true
  endpoints:
    web:
      exposure:
        include: "info, health, prometheus"

neo4j:
  url: "bolt://ec2-52-25-196-133.us-west-2.compute.amazonaws.com:7687"
  user: "neo4j"
  password: "i-05dc073078439197b"

prometheus:
  url: "http://prometheus.dev.asserts.ai"
  client:
    timeout: "30s"

logging:
  level:
    # Enable debug logging for all Asserts classes
#    ai:
#      asserts: "DEBUG"
    root: "INFO"
