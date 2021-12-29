module "k8s" {
  source = "./k8s-cluster"

  project   = var.project
  vpc_range = var.vpc_range
  region    = var.region
  node_pool = var.node_pool
}


module "kafka" {
  source = "./kafka-strimzi"

  strimzi_version = var.strimzi_version
  namespace       = var.namespace
  cluster         = var.cluster
  topic           = var.topic

  depends_on = [module.k8s]
}

module "registry" {
  source = "./container-registry"

  project     = var.project
  namespaces  = [var.namespace, "default"]
  secret_name = var.secret_name
}
