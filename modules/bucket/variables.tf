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

variable "enable_bucket_versioning" {
  type    = bool
  default = false
}

variable "bucket_policy_document" {
  type    = string
  default = null
}

variable "bucket_lifecycle_rules" {
  type = list(
    object(
      {
        prefix : string
        current_version_transitions : map(string)
        current_version_expiration : number
        noncurrent_version_transitions : map(string)
        noncurrent_version_expiration : number
      }
    )
  )
  default = []
}

variable "sse_algorithm" {
  type    = string
  default = "AES256"
}
