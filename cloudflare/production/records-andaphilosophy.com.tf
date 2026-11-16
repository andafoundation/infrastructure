locals {
  dns_records_andaphilosophy_com = {
    "_cf-custom-hostname.andaphilosophy.com/TXT" = { zone = "andaphilosophy.com", name = "_cf-custom-hostname.andaphilosophy.com", type = "TXT", content = "\"44a210f2-2cac-4698-a0f2-1cfd6f37cf92\"", proxied = false, ttl = 1 }
    "www.andaphilosophy.com/CNAME"               = { zone = "andaphilosophy.com", name = "www.andaphilosophy.com", type = "CNAME", content = "andaphilosophy.com", proxied = true, ttl = 1, comment = "Resolves www so the redirect to andaphilosophy.com can answer it" }
  }
}
