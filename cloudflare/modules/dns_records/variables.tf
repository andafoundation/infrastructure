variable "zone_ids" {}

# Typed here, unlike the other modules, because the rows come from untyped
# locals in the root (one file per zone): the optional() attributes are what
# turn a missing content, data, priority or comment into null. content is
# optional because Cloudflare derives it for an SRV record from data.
variable "dns_records" {
  type = map(object({
    zone     = string
    name     = string
    type     = string
    content  = optional(string)
    proxied  = bool
    ttl      = number
    priority = optional(number)
    comment  = optional(string)
    data = optional(object({
      port     = number
      priority = number
      weight   = number
      target   = string
    }))
  }))
}
