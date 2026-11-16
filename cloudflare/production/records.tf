# Every record of the managed zones except the read-only ones: the AAAA record that
# the Worker custom domain of andaphilosophy.com creates belongs to the Worker, not to
# this root. One file per zone, records-<zone>.tf, each holding one map; this file
# merges them into the map the dns_records module consumes. The merge cannot collide,
# because every key starts with the record's own name, which belongs to one zone.
#
# Map keys are "<name>/<type>". When one name holds several records of one type, each
# gets "/<n>": the records are sorted by their content in code-point order and
# numbered from 1 in that order. A record added later with that name and type would
# renumber the ones after it, which Terraform plans as a destroy and create; append
# it with the next free number instead, and keep the existing keys.
locals {
  dns_records = merge(
    local.dns_records_andaism_com,
    local.dns_records_andaphilosophy_com,
  )
}
