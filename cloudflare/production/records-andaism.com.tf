locals {
  dns_records_andaism_com = {
    "andaism.com/AAAA" = { zone = "andaism.com", name = "andaism.com", type = "AAAA", content = "100::", proxied = true, ttl = 1, comment = "Originless placeholder so the zone redirect to andaphilosophy.com can answer the apex" }
    # Google Workspace mail for andaism.com: delivery, SPF, domain verification and DKIM.
    "andaism.com/MX"    = { zone = "andaism.com", name = "andaism.com", type = "MX", content = "smtp.google.com", proxied = false, ttl = 1, priority = 10 }
    "andaism.com/TXT/1" = { zone = "andaism.com", name = "andaism.com", type = "TXT", content = "\"v=spf1 include:_spf.google.com ~all\"", proxied = false, ttl = 1 }
    "andaism.com/TXT/2" = { zone = "andaism.com", name = "andaism.com", type = "TXT", content = "\"google-site-verification=VUQCaXg3gZOXK3y22KdQmw15zZZFYO3boxXT32W34d8\"", proxied = false, ttl = 1 }
    # Cloudflare keeps a TXT value over 255 characters as quoted strings of at most 255 characters each,
    # so the DKIM key is held in that split form; any other form shows a change on every plan.
    "google._domainkey.andaism.com/TXT" = { zone = "andaism.com", name = "google._domainkey.andaism.com", type = "TXT", content = "\"v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAogUOf59SYqowbg+SPngjE//4ZQ2Acr0GttZ6CWahadXJurEqYaUjGQsqqitiSrimeAUFR7hIrRW5MI7dp4l/MCiwwT6ULMTWXwZaJfGlmMDfH9PqqxO4S0WjWw0/n1AW9ErVuln0aFNjT5Ue0gyLwj8yJ2ksZUf9FHft7AaH1gof2tgCIwHj2LjRykDUGSJJ2+r\" \"50qfjDbf+4CS9YWY5RtKJvZOmNfvoACDFO4+M1FvH2s98SeTgFVD5iQzwKCoeOaki2Al59vucA0HG69GU+U+vnhQFkwaDfQ8pfVx9y9SZ+nxw6ztSO7/FOfiC58Jw39p5pOHOjHJFZ8dG0Izi+QIDAQAB\"", proxied = false, ttl = 1 }
    "www.andaism.com/CNAME"             = { zone = "andaism.com", name = "www.andaism.com", type = "CNAME", content = "andaism.com", proxied = true, ttl = 1, comment = "Resolves www so the zone redirect to andaphilosophy.com can answer it" }
  }
}
