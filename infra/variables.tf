### k8s-cluster
variable "project" {
  type = string
}

variable "vpc_range" {
  type = string
}

variable "region" {
  type    = string
  default = "fra1"
}

variable "node_pool" {
  type = object({
    size       = string
    auto_scale = bool
    node_count = number
  })
}

### kafka-strimzi
variable "strimzi_version" {
  type = string
}

variable "namespace" {
  type = string
}

variable "cluster" {
  type = object({
    kafka = object({
      name         = string
      replicas     = number
      storage      = number
      delete_claim = bool
    })
    zookeeper = object({
      replicas     = number
      storage      = number
      delete_claim = bool
    })
  })
}

variable "topic" {
  type = object({
    name       = string
    partitions = number
    replicas   = number
  })
}

### container-registry
variable "secret_name" {
  type    = string
  default = ""
}
