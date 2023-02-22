variable "cloudflare_token" {
  description = "The Cloudflare API token to use for the certificate"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "The domain name for the certificate"
  type        = string
}

variable "environment" {
  description = "The environment for the certificate"
  type        = string
}

variable "brand-abbrev" {
  type        = string
  description = "The abbreviation of the brand to create the LDAP server for."

  validation {
    condition     = can(regex("^[a-zA-Z]+$", var.brand-abbrev))
    error_message = "The brand abbreviation can only contain letters."
  }
}

variable "brand-name" {
  type        = string
  description = "The name of the brand to create the LDAP server for."
}