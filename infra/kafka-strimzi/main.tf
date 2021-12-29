module "operator" {
  source = "./operator"

  namespace       = var.namespace
  strimzi_version = var.strimzi_version
}

module "cluster" {
  source = "./cluster"

  namespace = var.namespace
  cluster   = var.cluster

  depends_on = [module.operator]
}

resource "kubernetes_manifest" "topic" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name = var.topic.name
      labels = {
        "strimzi.io/cluster" = var.cluster.kafka.name
      }
      namespace = module.operator.namespace
    }
    spec = {
      partitions = var.topic.partitions
      replicas   = var.topic.replicas
    }
  }
  depends_on = [module.operator, module.cluster]
}

resource "kubernetes_config_map" "this" {
  metadata {
    name      = "kafka-client-config"
    namespace = var.namespace
  }

  data = {
    bootstrap_servers = "${var.cluster.kafka.name}-kafka-bootstrap:9092"
    topic             = var.topic.name
    group_id          = "kafka-consumers"
  }
  depends_on = [module.operator, module.cluster]
}
