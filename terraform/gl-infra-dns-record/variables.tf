variable "zone" {
  type        = string
  description = "Zone. Fully qualified, with trailing period. E.g. `gitlab.com.`."

  validation {
    condition     = can(regex("[\\w-]+\\.[\\w-]+\\.$", var.zone))
    error_message = "The zone must be a valid FQDN with a trailing period."
  }
}

variable "a" {
  type = map(object({
    records = list(string)
    ttl     = number
    proxied = optional(bool, false)
    spectrum_config = optional(object({
      ip_firewall           = optional(bool, true)
      ip_override           = optional(list(string), [])
      ports                 = map(string)
      proxy_protocol        = optional(string, "off")
      edge_ips_type         = optional(string, "dynamic")
      edge_ips_connectivity = optional(string, "all")
      argo_smart_routing    = optional(bool, false)
    }))
  }))
  description = "A records."
  default     = {}
}

variable "aaaa" {
  type = map(object({
    records = list(string)
    ttl     = number
    proxied = optional(bool, false)
    spectrum_config = optional(object({
      ip_firewall           = optional(bool, true)
      ip_override           = optional(list(string), [])
      ports                 = map(string)
      proxy_protocol        = optional(string, "off")
      edge_ips_type         = optional(string, "dynamic")
      edge_ips_connectivity = optional(string, "all")
      argo_smart_routing    = optional(bool, false)
    }))
  }))
  description = "AAAA records."
  default     = {}
}

variable "caa" {
  type = map(object({
    records = list(object({
      flags = number
      tag   = string
      value = string
    }))
    ttl = number
  }))
  description = "CAA records."
  default     = {}
}

variable "cname" {
  type = map(object({
    records = list(string)
    proxied = optional(bool, false)
    ttl     = number
  }))
  description = "CNAME records."
  default     = {}
}

variable "mx" {
  type = map(object({
    records = list(object({
      prio  = number
      value = string
    }))
    ttl = number
  }))
  description = "MX records."
  default     = {}
}

variable "ns" {
  type = map(object({
    records = list(string)
    proxied = optional(bool, false)
    ttl     = number
  }))
  description = "NS records."
  default     = {}
}

variable "soa" {
  type = map(object({
    records = list(string)
    proxied = optional(bool, false)
    ttl     = number
  }))
  description = "SOA records."
  default     = {}
}

variable "txt" {
  type = map(object({
    records = list(string)
    proxied = optional(bool, false)
    ttl     = number
  }))
  description = "TXT records."
  default     = {}
}
