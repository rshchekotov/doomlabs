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

variable "gitea-postgres-user" {
  type        = string
  description = "The user to use for the Gitea Postgres database."
}

variable "gitea-postgres-password" {
  type        = string
  description = "The password to use for the Gitea Postgres database."
  sensitive   = true
}

variable "gitea-admin-name" {
  type        = string
  description = "The name of the Gitea admin user."
}

variable "gitea-admin-email" {
  type        = string
  description = "The email of the Gitea admin user."
}

variable "gitea-admin-password" {
  type        = string
  description = "The password of the Gitea admin user."
  sensitive   = true
}

variable "ldap-host" {
  type        = string
  description = "The host of the LDAP server to connect to."
}

variable "ldap-port" {
  type        = number
  description = "The port of the LDAP server to connect to."
  default     = 389
}

variable "ldap-bind-dn" {
  type        = string
  description = "The bind DN to use to connect to the LDAP server."
}

variable "ldap-bind-password" {
  type        = string
  description = "The bind password to use to connect to the LDAP server."
  sensitive   = true
}

variable "ldap-user-filter" {
  type        = string
  description = "The user filter for the LDAP server."
}

variable "ldap-admin-filter" {
  type        = string
  description = "The admin filter for the LDAP server."
}

variable "ldap-user-base" {
  type        = string
  description = "The user base for the LDAP server."
}

variable "ldap-attribute-username" {
  type        = string
  description = "The username attribute for the LDAP server."
  default     = "uid"
}

variable "ldap-attribute-email" {
  type        = string
  description = "The email attribute for the LDAP server."
  default     = "mail"
}

variable "ldap-attribute-first-name" {
  type        = string
  description = "The first name attribute for the LDAP server."
  default     = "givenName"
}

variable "ldap-attribute-last-name" {
  type        = string
  description = "The last name attribute for the LDAP server."
  default     = "sn"
}