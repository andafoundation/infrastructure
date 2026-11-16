# The SSL mode of each zone. "strict" validates the origin certificate; the site is a
# Worker, which Cloudflare serves itself. andaism.com has no origin at all (every
# request is redirected), so "full" there changes nothing.
#
# redirect_to makes the zone an alias of another domain: every request to any
# hostname of the zone gets a 301 to the same path and query string on
# https://<redirect_to>. Only proxied hostnames reach the redirect, so each one
# the alias should answer for needs a proxied record in records-<zone>.tf. A zone
# holds one ruleset per phase, so a zone that already has an
# http_request_dynamic_redirect ruleset in Cloudflare must have it imported first.
#
# www_redirect sends www.<zone> to the root domain with a 301, path and query string
# kept. It needs a proxied www record in records-<zone>.tf. It takes the same ruleset
# slot, so it cannot be combined with redirect_to, and the import rule above applies too.
variable "zones" {
  type = map(object({
    ssl_mode     = string
    redirect_to  = optional(string)
    www_redirect = optional(bool, false)
  }))
  default = {
    "andaism.com"        = { ssl_mode = "full", redirect_to = "andaphilosophy.com" }
    "andaphilosophy.com" = { ssl_mode = "strict", www_redirect = true }
  }
}
