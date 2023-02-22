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

variable "environment" {
  type        = string
  description = "The environment to deploy the LDAP server to."

  validation {
    condition     = contains(["develop", "production"], var.environment)
    error_message = "The environment must be either develop or production."
  }
}

variable "host_name" {
  type        = string
  description = "The name (without TLD's or Subdomains) of the host to create the LDAP server on."
}

variable "host_tld" {
  type        = string
  description = "The TLD of the host to create the LDAP server on."
}

variable "network-name" {
  type        = string
  description = "The name of the network to create the LDAP server on."
}

variable "ldap_host" {
  type        = string
  description = "Hostname for the LDAP Container"
}

variable "volume-certificates" {
  type        = string
  description = "The name of the volume to store the certificates in."
}