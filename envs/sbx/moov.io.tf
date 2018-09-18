resource "google_dns_managed_zone" "moov-io" {
  name        = "moov-io"
  dns_name    = "moov.io."
  description = "moov.io root zone"
}

// pro tip: 'host -a moov.io' lists all records

// moov.io
resource "google_dns_record_set" "moov-A" {
  name = "moov.io"
  type = "A"
  ttl = 60

  managed_zone = "${google_dns_managed_zone.moov-io.dns_name}"

  # github pages
  rrdatas = ["185.199.108.153", "185.199.111.153", "185.199.109.153", "185.199.110.153"]
}

resource "google_dns_record_set" "moov-SPF" {
  name = "frontend.${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type = "TXT"
  ttl  = 60

  rrdatas = ["\"v=spf1 include:_spf.google.com ~all\""]
}

resource "google_dns_record_set" "moov-MX" {
  name = "${google_dns_managed_zone.moov-io.dns_name}"
  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  type = "MX"
  ttl  = 60

  rrdatas = [
    "5 alt2.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "1 aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
  ]
}

// api.moov.io
data "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = "lb"
  }
}

resource "google_dns_record_set" "api" {
  name = "api.${google_dns_managed_zone.moov-io.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${google_dns_managed_zone.moov-io.name}"
  rrdatas = ["${data.kubernetes_service.traefik.load_balancer_ingress.0.ip}"]
}
