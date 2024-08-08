variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "read_access_entities" {
  description = "The arn of entities that can read from the bucket"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.read_access_entities : can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", arn))
    ])
    error_message = "Each read access entity must be a valid IAM role ARN."
  }
}

variable "write_access_entities" {
  description = "The arn of entities that can write to the bucket"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.write_access_entities : can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", arn))
    ])
    error_message = "Each write access entity must be a valid IAM role ARN."
  }
}
