variable "bucket_name" {
  type = string
}

variable "bucket_prefix" {
  type = string
}

variable "bucket_tags" {
  type    = map(string)
  default = {}
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "block_public_access" {
  type    = bool
  default = true
}

variable "bucket_policy_document" {
  type    = string
  default = null
}
