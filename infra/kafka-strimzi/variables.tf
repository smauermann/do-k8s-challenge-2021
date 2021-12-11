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
