resource "kubernetes_namespace" "this" {
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
    namespace = kubernetes_namespace.this.metadata[0].name
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

  depends_on = [null_resource.artifacts, kubernetes_namespace.this]
}
