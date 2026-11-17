# No API token can create a zone, so both zones are added in the Cloudflare
# dashboard of the Anda account and adopted here by their zone ids (Overview page of
# each zone, "Zone ID"). Once applied, the imports are no-ops: Terraform skips an
# import whose address is already in state.
locals {
  imported_zone_ids = {
    "andaism.com"        = "703dc53c723c2196ee3ad032d62e7a93"
    "andaphilosophy.com" = "b06231a1a43a7b7457082587359eba53"
  }
}

import {
  for_each = local.imported_zone_ids
  to       = module.zones.cloudflare_zone.zones[each.key]
  id       = each.value
}
