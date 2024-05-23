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
