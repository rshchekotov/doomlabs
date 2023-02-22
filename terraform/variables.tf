#region Environment Variables
variable "os" {
  type        = string
  description = "Host Operating System"
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.os)
    error_message = "Host Operating System must be either linux or windows."
  }
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "develop"

  validation {
    condition     = contains(["develop", "production"], var.environment)
    error_message = "Environment must be either develop or production."
  }
}
#endregion

#region Naming / Branding Variables
variable "brand" {
  type        = string
  description = "Brand name"
  default     = "Doomlabs"

  validation {
    condition     = can(regex("^[a-zA-Z]+$", var.brand))
    error_message = "Brand name must contain only letters."
  }
}

variable "brand-abbrev" {
  type        = string
  description = "Brand abbreviation"
  default     = "DL"

  validation {
    condition     = can(regex("^[a-zA-Z]+$", var.brand-abbrev))
    error_message = "Brand abbreviation must contain only letters."
  }
}
#endregion

#region Domain / Hosting Variables
variable "host_name" {
  type        = string
  description = "Host name"
  default     = "doomlabs"

  validation {
    condition     = can(regex("^[a-z0-9-]*$", var.host_name))
    error_message = "Host name can only contain lowercase letters, numbers, and dashes."
  }
}

variable "host_tld" {
  type        = string
  description = "Host TLD"
  default     = "org"

  validation {
    condition     = can(regex("^[a-z0-9]{2,}$", var.host_tld))
    error_message = "Host TLD can only contain lowercase letters and numbers."
  }
}

variable "cloudflare_token" {
  type        = string
  description = "Cloudflare Token (Required for TLS Certificates)"
  sensitive   = true
  default     = ""
}
#endregion

#region LDAP Variables
variable "ldap_group_memberships" {
  description = "LDAP Group Memberships"
  type        = map(list(string))
  sensitive   = true
}

variable "ldap_organization" {
  type        = string
  description = "LDAP Organization"
  default     = "Doomlabs"
}

variable "ldap_users" {
  description = "LDAP Users"
  type = list(object({
    uid        = string
    first_name = string
    last_name  = string
    email      = string
    password   = string
    state      = string
    city       = string
    country    = string
  }))
  sensitive = true
}

variable "ldap_root_password" {
  type        = string
  description = "LDAP Root Password"
  sensitive   = true
}
#endregion