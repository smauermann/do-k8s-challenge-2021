resource "kubernetes_namespace" "cluster" {
  metadata {
    name = var.namespace
  }
}

resource "null_resource" "artifacts" {
  triggers = {
    version = var.strimzi_version
  }

  provisioner "local-exec" {
    when    = create
    command = "./${path.module}/bin/create-artifacts.sh"
    environment = {
      STRIMZI_ARTIFACT = "strimzi-${self.triggers.version}"
      STRIMZI_VERSION  = self.triggers.version
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "./${path.module}/bin/destroy-artifacts.sh"
    environment = {
      STRIMZI_ARTIFACT = "strimzi-${self.triggers.version}"
    }
  }
}

resource "null_resource" "operator" {
  triggers = {
    version   = var.strimzi_version
    namespace = kubernetes_namespace.cluster.metadata[0].name
  }

  provisioner "local-exec" {
    when    = create
    command = "./${path.module}/bin/create-operator.sh"
    environment = {
      STRIMZI_ARTIFACT = "strimzi-${self.triggers.version}"
      STRIMZI_VERSION  = self.triggers.version
      NAMESPACE        = self.triggers.namespace
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "./${path.module}/bin/destroy-operator.sh"
    environment = {
      STRIMZI_ARTIFACT = "strimzi-${self.triggers.version}"
      NAMESPACE        = self.triggers.namespace
    }
  }

  depends_on = [null_resource.artifacts, kubernetes_namespace.cluster]
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = var.cluster.kafka.name
      namespace = kubernetes_namespace.cluster.metadata[0].name
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
          },
          {
            name = "external"
            port = 9094
            type = "nodeport"
            tls  = false
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
  depends_on = [null_resource.operator]
}

# TODO one can probably achieve the same with the `wait_for` attribute of the `kubernetes_manifest` resource
resource "null_resource" "wait_cluster" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
    kubectl wait kafka/${var.cluster.kafka.name} \
      --for=condition=Ready --timeout=300s \
      -n ${kubernetes_namespace.cluster.metadata[0].name}"
    EOT
  }
  depends_on = [kubernetes_manifest.cluster]
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
      namespace = kubernetes_namespace.cluster.metadata[0].name
    }
    spec = {
      partitions = var.topic.partitions
      replicas   = var.topic.replicas
    }
  }
  depends_on = [null_resource.operator]
}
