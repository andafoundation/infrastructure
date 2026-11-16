resource "cloudflare_zone" "zones" {
  for_each = var.zones
  account  = { id = var.account_id }
  name     = each.key
  type     = "full"

  # Deleting a zone takes every hostname in it offline and gives up the zone's
  # name servers; no Terraform change should ever be able to do that.
  lifecycle {
    prevent_destroy = true
  }
}
