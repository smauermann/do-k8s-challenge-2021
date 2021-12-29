resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = var.cluster.kafka.name
      namespace = var.namespace
    }
    spec = {
      kafka = {
        replicas = var.cluster.kafka.replicas
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
            authentication = {
              type = "tls"
            }
          }
        ]
        storage = {
          type = "jbod"
          volumes = [{
            id          = 0
            type        = "persistent-claim"
            size        = "${var.cluster.kafka.storage}Gi"
            deleteClaim = var.cluster.kafka.delete_claim
          }]
        }
        config = {
          "offsets.topic.replication.factor"         = 1
          "transaction.state.log.replication.factor" = 1
          "transaction.state.log.min.isr"            = 1
        }
      }
      zookeeper = {
        replicas = var.cluster.zookeeper.replicas
        storage = {
          type        = "persistent-claim"
          size        = "${var.cluster.zookeeper.storage}Gi"
          deleteClaim = var.cluster.zookeeper.delete_claim
        }
      }
      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }
}

# TODO one can probably achieve the same with the `wait_for` attribute of the `kubernetes_manifest` resource
resource "null_resource" "wait_cluster" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
    kubectl wait kafka/${var.cluster.kafka.name} \
      --for=condition=Ready --timeout=300s \
      -n ${var.namespace}
    EOT
  }
  depends_on = [kubernetes_manifest.cluster]
}
