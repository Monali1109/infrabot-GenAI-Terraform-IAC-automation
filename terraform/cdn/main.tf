# ── GCP Cloud CDN: cdn-1778075847251 (dev) ─────────────────────────────────
resource "google_compute_backend_bucket" "cdn-1778075847251" {
  name        = "cdn-1778075847251-cdn-policy-dev"
  bucket_name = "gs://gcpdevstaticfiles"
  enable_cdn  = true

  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 1800
    max_ttl     = 12600
    client_ttl  = 1800
    serve_while_stale = 86400
  }
}

resource "google_compute_url_map" "cdn-1778075847251_urlmap" {
  name            = "cdn-1778075847251-cdn-policy-dev-urlmap"
  default_service = google_compute_backend_bucket.cdn-1778075847251.id
}

resource "google_compute_target_http_proxy" "cdn-1778075847251_proxy" {
  name    = "cdn-1778075847251-cdn-policy-dev-proxy"
  url_map = google_compute_url_map.cdn-1778075847251_urlmap.id
}

resource "google_compute_global_forwarding_rule" "cdn-1778075847251_forwarding" {
  name       = "cdn-1778075847251-cdn-policy-dev-forwarding"
  target     = google_compute_target_http_proxy.cdn-1778075847251_proxy.id
  port_range = "80"
}

output "cdn-1778075847251_cdn_backend"   { value = google_compute_backend_bucket.cdn-1778075847251.self_link }
output "cdn-1778075847251_url_map"       { value = google_compute_url_map.cdn-1778075847251_urlmap.id }
output "cdn-1778075847251_forwarding_ip" { value = google_compute_global_forwarding_rule.cdn-1778075847251_forwarding.ip_address }