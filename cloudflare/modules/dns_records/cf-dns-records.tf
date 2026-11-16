resource "cloudflare_dns_record" "records" {
  for_each = var.dns_records
  zone_id  = var.zone_ids[each.value.zone]
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  data     = each.value.data
  proxied  = each.value.proxied
  ttl      = each.value.ttl
  priority = each.value.priority
  comment  = each.value.comment
}
