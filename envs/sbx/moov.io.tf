resource "google_dns_managed_zone" "moov-io" {
  name        = "moov-io"
  dns_name    = "moov.io."
  description = "moov.io root zone"
}

// pro tip: 'host -a moov.io' lists all records

// moov.io
resource "google_dns_record_set" "moov-A" {
  name         = "${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "A"
  ttl          = 60

  # github pages
  rrdatas = ["185.199.108.153", "185.199.111.153", "185.199.109.153", "185.199.110.153"]
}

resource "google_dns_record_set" "moov-SPF" {
  name         = "${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "TXT"
  ttl          = 60

  rrdatas = ["\"v=spf1 include:_spf.google.com ~all\""]
}

resource "google_dns_record_set" "moov-MX" {
  name         = "${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "MX"
  ttl          = 60

  rrdatas = [
    "5 alt2.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "1 aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
  ]
}

resource "google_dns_record_set" "moov-CAA" {
  name         = "${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "CAA"
  ttl          = 60

  rrdatas = [
    // Cloudflare
    // https://support.cloudflare.com/hc/en-us/articles/115000310832-Certification-Authority-Authorization-CAA-FAQ
    "0 issue \"comodoca.com\"",
    "0 issuewild \"comodoca.com\"",
    "0 issue \"digicert.com\"",
    "0 issuewild \"digicert.com\"",
    "0 issue \"globalsign.com\"",
    "0 issuewild \"globalsign.com\"",

    // future google ca
    "0 issue \"google.com\"",
    "0 issuewild \"google.com\"",

    // ACME
    "0 issue \"letsencrypt.org\"",
    "0 issuewild \"letsencrypt.org\"",

    // notify us
    "0 iodef \"mailto:security@moov.io\"",
  ]
}

data "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = "lb"
  }
}

resource "google_dns_record_set" "api" {
  name         = "api.${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "A"
  ttl          = 60

  rrdatas = ["${data.kubernetes_service.traefik.load_balancer_ingress.0.ip}"]
}

resource "google_dns_record_set" "infra" {
  name         = "infra.${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type         = "A"
  ttl          = 60

  rrdatas = ["${data.kubernetes_service.traefik.load_balancer_ingress.0.ip}"]
}
