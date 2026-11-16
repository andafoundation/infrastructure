# A zone with redirect_to is an alias of another domain. The redirect runs at the
# edge, before the origin, so the alias needs no Worker route or certificate of
# its own. The target is always https, so a plain HTTP request also lands on
# the canonical domain in one hop. 301 because the alias is permanent and search
# engines should move their index to the target.
resource "cloudflare_ruleset" "zone_redirect" {
  for_each = { for name, zone in var.zones : name => zone if zone.redirect_to != null }
  zone_id  = cloudflare_zone.zones[each.key].id
  name     = "Redirect ${each.key} to ${each.value.redirect_to}"
  kind     = "zone"
  phase    = "http_request_dynamic_redirect"

  rules = [{
    description = "Every hostname of ${each.key} to https://${each.value.redirect_to}, path and query kept"
    expression  = "true"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code           = 301
        preserve_query_string = true
        target_url = {
          expression = "concat(\"https://${each.value.redirect_to}\", http.request.uri.path)"
        }
      }
    }
  }]
}

# A zone with www_redirect serves its site on the root domain only. The www hostname
# is redirected at the edge for the same reasons as an alias: it needs no Worker route
# or certificate of its own, and search engines index one hostname.
resource "cloudflare_ruleset" "www_redirect" {
  for_each = { for name, zone in var.zones : name => zone if zone.www_redirect }
  zone_id  = cloudflare_zone.zones[each.key].id
  name     = "Redirect www.${each.key} to ${each.key}"
  kind     = "zone"
  phase    = "http_request_dynamic_redirect"

  rules = [{
    description = "www.${each.key} to https://${each.key}, path and query kept"
    expression  = "http.host eq \"www.${each.key}\""
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code           = 301
        preserve_query_string = true
        target_url = {
          expression = "concat(\"https://${each.key}\", http.request.uri.path)"
        }
      }
    }
  }]
}
