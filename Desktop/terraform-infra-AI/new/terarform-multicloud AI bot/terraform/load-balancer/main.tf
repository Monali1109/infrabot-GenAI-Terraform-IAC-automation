resource "google_compute_health_check" "app" {
  name               = "hc-gcp-dev-app"
  check_interval_sec = 30
  timeout_sec        = 10

  https_health_check {
    port         = 443
    request_path = "/health"
  }
}

resource "google_compute_backend_service" "app" {
  name          = "bs-gcp-dev-app"
  protocol      = "HTTPS"
  health_checks = [google_compute_health_check.app.id]

  backend {
    group = var.instance_group
  }
}

resource "google_compute_url_map" "main" {
  name            = "lb-gcp-dev-urlmap"
  default_service = google_compute_backend_service.app.id
}

resource "google_compute_target_https_proxy" "main" {
  name             = "lb-gcp-dev-https-proxy"
  url_map          = google_compute_url_map.main.id
  ssl_certificates = [var.ssl_certificate]
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "lb-gcp-dev-forwarding-rule"
  target     = google_compute_target_https_proxy.main.id
  port_range = "443"
}
