# managed by Helm
server:
  port: 8030
  servlet:
    context-path: "/assertion-verifier"

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

# exclude nulls from api responses
spring:
  jackson:
    default-property-inclusion: NON_NULL

logging:
  level:
    # Enable debug logging for all Asserts classes
#    ai:
#      asserts: "DEBUG"
    root: "INFO"
