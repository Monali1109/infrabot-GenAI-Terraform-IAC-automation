resource "google_dns_managed_zone" "main" {
  name        = "dns-gcp-prod-zone"
  dns_name    = "prod.example.internal."
  description = "Private DNS zone for prod"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.network_url
    }
  }

  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}

resource "google_dns_record_set" "app" {
  name         = "app.prod.example.internal."
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.app_private_ip]
}

resource "google_dns_record_set" "db" {
  name         = "db.prod.example.internal."
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.db_private_ip]
}
