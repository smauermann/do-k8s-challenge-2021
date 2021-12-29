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
