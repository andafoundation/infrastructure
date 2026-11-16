output "zone-ids" {
  value = { for name, zone in cloudflare_zone.zones : name => zone.id }
}
