locals {
  dns_records_andaism_com = {
    "andaism.com/AAAA"      = { zone = "andaism.com", name = "andaism.com", type = "AAAA", content = "100::", proxied = true, ttl = 1, comment = "Originless placeholder so the zone redirect to andaphilosophy.com can answer the apex" }
    "www.andaism.com/CNAME" = { zone = "andaism.com", name = "www.andaism.com", type = "CNAME", content = "andaism.com", proxied = true, ttl = 1, comment = "Resolves www so the zone redirect to andaphilosophy.com can answer it" }
  }
}
