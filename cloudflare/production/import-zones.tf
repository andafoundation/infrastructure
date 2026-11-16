# No API token can create a zone, so both zones are added in the Cloudflare
# dashboard of the Anda account and adopted here by their zone ids (Overview page of
# each zone, "Zone ID"). Once applied, the imports are no-ops: Terraform skips an
# import whose address is already in state.
locals {
  imported_zone_ids = {
    "andaism.com"        = "<ANDAISM_COM_ZONE_ID>"
    "andaphilosophy.com" = "<ANDAPHILOSOPHY_COM_ZONE_ID>"
  }
}

import {
  for_each = local.imported_zone_ids
  to       = module.zones.cloudflare_zone.zones[each.key]
  id       = each.value
}
