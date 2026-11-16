module "zones" {
  source     = "../modules/zones"
  account_id = var.cloudflare_account_id
  zones      = var.zones
}

module "dns_records" {
  source      = "../modules/dns_records"
  zone_ids    = module.zones.zone-ids
  dns_records = local.dns_records
}
