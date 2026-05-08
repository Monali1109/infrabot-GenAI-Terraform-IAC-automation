# After running virtual-network, find VPC ID in AWS Console:
#   VPC -> Your VPCs -> search Name = "VPC_AWS_DEV-01"
vpc_id     = "vpc-REPLACE_AFTER_VPC_DEPLOY"
admin_cidr = "10.0.0.0/8"


# ── dev environment ─────────────────────────────────────────
aws_region        = "us-east-1"
tf_state_bucket   = "my-tfstate-dev"
project_name      = "myproject"

# ── Generation gmowqdugm ──
gmowqdugm_direction = "Egress / Outbound"
gmowqdugm_protocol = "tcp"
gmowqdugm_source_ip = "10.20.0.235"
gmowqdugm_dest_ip = "198.168.20.73"