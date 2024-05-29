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
        id     = string
        status = string
        transitions = list(
          object(
            {
              days          = number
              storage_class = string
            }
          )
        )
      }
    )
  )

  default = [
    {
      id     = "rule"
      status = "Enabled"
      transitions = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}
