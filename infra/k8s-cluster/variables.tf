variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "node_pool" {
  type = object({
    size       = string
    auto_scale = bool
    node_count = number
  })
}

variable "vpc_range" {
  type = string
}
