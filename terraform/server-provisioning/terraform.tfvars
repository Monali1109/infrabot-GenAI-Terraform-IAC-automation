region = "us-east-1"

# After running virtual-network, find subnet ID in AWS Console:
#   EC2 -> Subnets -> search Name = "SUBNET_AWS_APP_DEV-01"
subnet_id = "subnet-REPLACE_AFTER_VPC_DEPLOY"

# EC2 -> Key Pairs -> use existing or create one
key_name  = "REPLACE_WITH_YOUR_KEY_PAIR_NAME"


# ── dev environment ─────────────────────────────────────────
aws_region        = "us-east-1"
tf_state_bucket   = "my-tfstate-dev"
project_name      = "myproject"

# ── Generation gmosvqdss ──
gmosvqdss_instance_type = "r5.xlarge"
gmosvqdss_ami_os = "Windows Server 2019"
gmosvqdss_volume_size = "100"
gmosvqdss_server_name = "AWSDBPD02"
gmosvqdss_availability_zone = "us-east-1a"
gmosvqdss_additional_disks = "D:40,E:76"
gmosvqdss_machine_type_note = ""m5.xlarge" has 4 vCPU / 16 GB RAM — no m5 type meets 4 vCPU / 32 GB. Using closest available: r5.xlarge (4 vCPU / 32 GB RAM · Memory-optimised)"
gmosvqdss_image = "windows-cloud/windows-2019"
gmosvqdss_image_publisher = "MicrosoftWindowsServer"
gmosvqdss_machine_type = "n2-highmem-4"
gmosvqdss_vm_size = "Standard_D4s_v3"
gmosvqdss_zone = "us-east-1a"
gmosvqdss_admin_email = "mopatil@deloitte.com"
gmosvqdss_admin_role = "Administrator"
gmosvqdss_user_email = "mopatil@deloitte.com"
gmosvqdss_role = "roles/owner"
gmosvqdss_service_access = "EC2"
gmosvqdss_ram_gb = "32"
gmosvqdss_cpu_cores = "4"