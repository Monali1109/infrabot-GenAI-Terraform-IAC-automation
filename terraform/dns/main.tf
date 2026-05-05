resource "google_dns_managed_zone" "main" {
  name        = "dns-gcp-dev-zone"
  dns_name    = "dev.example.internal."
  description = "Private DNS zone for dev"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_url
    }
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "google_dns_record_set" "app" {
  name         = "app.dev.example.internal."
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.app_private_ip]
}

resource "google_dns_record_set" "db" {
  name         = "db.dev.example.internal."
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.db_private_ip]
}
