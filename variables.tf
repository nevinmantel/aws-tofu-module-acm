variable "certs" {
  description = <<EOT
Map of ACM certificates to create.
Key = identifier
Value = object:
  - domain_name       (string)
  - validation_method ("manual" or "automatic")
  - zone_id           (string, required if validation_method = "automatic")
EOT
  type = map(object({
    domain_name       = string
    validation_method = string
    zone_id           = optional(string, null)
  }))

  validation {
    condition     = alltrue([for v in values(var.certs) : contains(["manual", "automatic"], v.validation_method)])
    error_message = "validation_method must be either 'manual' or 'automatic'."
  }

  validation {
    condition = alltrue([
      for v in values(var.certs) : (
        v.validation_method == "manual" || (v.validation_method == "automatic" && v.zone_id != null)
      )
    ])
    error_message = "If validation_method = 'automatic', zone_id must be provided."
  }
}