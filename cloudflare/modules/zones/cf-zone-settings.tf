resource "cloudflare_zone_setting" "ssl" {
  for_each   = var.zones
  zone_id    = cloudflare_zone.zones[each.key].id
  setting_id = "ssl"
  value      = each.value.ssl_mode
}

# Every hostname of these zones is served or redirected at the edge over HTTPS, so a
# plain HTTP request has no other useful answer than a redirect to HTTPS.
resource "cloudflare_zone_setting" "always_use_https" {
  for_each   = var.zones
  zone_id    = cloudflare_zone.zones[each.key].id
  setting_id = "always_use_https"
  value      = "on"
}
