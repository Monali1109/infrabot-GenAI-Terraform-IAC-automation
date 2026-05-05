# ── prod environment ─────────────────────────────────────────
aws_region        = "us-east-1"
tf_state_bucket   = "my-tfstate-prod"
project_name      = "myproject"

# ── Generation gmosm77g2 ──
gmosm77g2_direction = "egress"
gmosm77g2_protocol = "tcp"
gmosm77g2_source_ip = "10.20.0.23"
gmosm77g2_dest_ip = "198.168.20.7"