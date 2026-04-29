# ── dev environment ─────────────────────────────────────────
gcp_project_id  = "my-project-dev"
gcp_region      = "us-central1"
tf_state_bucket = "my-tfstate-dev"
project_name    = "myproject"

# ── Generation gmojzqste ──
gmojzqste_direction = "INGRESS"
gmojzqste_protocol = "tcp"
gmojzqste_ports = "443"
gmojzqste_target_tags = "web"
gmojzqste_source_ip = "10.20.0.155/23"
gmojzqste_dest_ip = "198.234.0.54"
gmojzqste_port_range = "8000"