resource "kong_service" "ach" {
  name            = "ach"
  protocol        = "http"
  host            = "ach"
  port            = 8080
  path            = "/"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "ach" {
  name           = "ach"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [ "/v1/ach" ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.ach.id
}

resource "kong_service" "accounts" {
  name            = "accounts"
  protocol        = "http"
  host            = "accounts"
  port            = 8085
  path            = "/"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "accounts" {
  name           = "accounts"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [ "/v1/accounts" ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.accounts.id
}

resource "kong_service" "auth" {
  name            = "auth"
  protocol        = "http"
  host            = "auth"
  port            = 8081
  path            = "/"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "auth" {
  name           = "auth"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [
    "/v1/auth",
    "/v1/oauth2",
    "/v1/users",
  ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.auth.id
}

resource "kong_service" "customers" {
  name            = "customers"
  protocol        = "http"
  host            = "customers"
  port            = 8087
  path            = "/customers"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "customers" {
  name           = "customers"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [
    "/v1/customers",
  ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.customers.id
}

resource "kong_service" "fed" {
  name            = "fed"
  protocol        = "http"
  host            = "fed"
  port            = 8086
  path            = "/fed"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "fed" {
  name           = "fed"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [
    "/v1/fed",
  ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.fed.id
}

resource "kong_service" "paygate" {
  name            = "paygate"
  protocol        = "http"
  host            = "paygate"
  port            = 8082
  path            = "/"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "paygate" {
  name           = "paygate"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [
    "/v1/ach/depositories",
    "/v1/ach/events",
    "/v1/ach/gateways",
    "/v1/ach/originators",
    "/v1/ach/receivers",
    "/v1/ach/transfers",
    "/v1/paygate/",
  ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.paygate.id
}

resource "kong_service" "watchman" {
  name            = "watchman"
  protocol        = "http"
  host            = "watchman"
  port            = 8084
  path            = "/"
  retries         = 5
  connect_timeout = 1000
  write_timeout   = 1000
  read_timeout    = 1000
}

resource "kong_route" "watchman" {
  name           = "watchman"
  protocols      = [ "http" ]
  methods        = [ "GET", "POST", "DELETE" ]
  # hosts 	 = [ "local.moov.io" ]
  paths 	 = [
    "/v1/watchman",
  ]
  strip_path     = true
  preserve_host  = false
  regex_priority = 1
  service_id     = kong_service.watchman.id
}
