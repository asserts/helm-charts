# managed by Helm
rules:
  source: FILE
  path: "conf/rules.yml"

neo4j:
  url: "bolt://ec2-52-25-196-133.us-west-2.compute.amazonaws.com:7687"
  user: "neo4j"
  password: "i-05dc073078439197b"

prometheus:
  url: "http://prometheus.dev.asserts.ai"
  client:
    timeout: "30s"
