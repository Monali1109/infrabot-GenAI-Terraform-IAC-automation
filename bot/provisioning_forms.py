"""provisioning_forms.py — Streamlit form components for all 3 clouds × 3 workflows.

Renders all fields at once with dropdowns. Returns a dict of template_inputs
that can be passed directly to render_template().
"""

import streamlit as st

# ═════════════════════════════════════════════════════════════════════════════
# AWS OPTIONS
# ═════════════════════════════════════════════════════════════════════════════

AWS_REGIONS = [
    "us-east-1", "us-east-2", "us-west-1", "us-west-2",
    "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "eu-north-1",
    "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-northeast-2",
    "ca-central-1", "sa-east-1", "me-south-1", "af-south-1",
]

AWS_INSTANCE_TYPES = [
    # General Purpose
    "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge",
    "t3a.micro", "t3a.small", "t3a.medium", "t3a.large", "t3a.xlarge",
    "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge", "m5.8xlarge",
    "m5a.large", "m5a.xlarge", "m5a.2xlarge", "m5a.4xlarge",
    "m6i.large", "m6i.xlarge", "m6i.2xlarge", "m6i.4xlarge",
    "m7i.large", "m7i.xlarge", "m7i.2xlarge",
    # Compute Optimized
    "c5.large", "c5.xlarge", "c5.2xlarge", "c5.4xlarge", "c5.9xlarge",
    "c6i.large", "c6i.xlarge", "c6i.2xlarge", "c6i.4xlarge",
    "c7i.large", "c7i.xlarge", "c7i.2xlarge",
    # Memory Optimized
    "r5.large", "r5.xlarge", "r5.2xlarge", "r5.4xlarge",
    "r6i.large", "r6i.xlarge", "r6i.2xlarge",
    # Storage Optimized
    "i3.large", "i3.xlarge", "i3.2xlarge",
    "d3.xlarge", "d3.2xlarge",
    # GPU
    "p3.2xlarge", "p3.8xlarge", "p4d.24xlarge",
    "g4dn.xlarge", "g4dn.2xlarge", "g5.xlarge", "g5.2xlarge",
]

AWS_AMIS = {
    "Amazon Linux 2023":           "ami-0c02fb55956c7d316",
    "Amazon Linux 2":              "ami-0cff7528ff583bf9a",
    "Ubuntu 24.04 LTS":           "ami-0e1bed4f06a3b463d",
    "Ubuntu 22.04 LTS":           "ami-0261755bbcb8c4a84",
    "Ubuntu 20.04 LTS":           "ami-0149b2da6ceec4bb0",
    "Red Hat Enterprise Linux 9":  "ami-0c9978668f8d55984",
    "Red Hat Enterprise Linux 8":  "ami-0c41531b8d18cc72b",
    "SUSE Linux Enterprise 15":    "ami-0df53967d89a9a1ec",
    "Debian 12":                   "ami-0a59c5eb57f0c0b2c",
    "Debian 11":                   "ami-09d3b3274b6c5d4aa",
    "Windows Server 2022":         "ami-0c2b8ca1dad447f8a",
    "Windows Server 2019":         "ami-0aeeebd8d2ab47354",
    "Custom AMI (enter manually)": "",
}

AWS_STORAGE_TYPES = ["gp3", "gp2", "io1", "io2", "st1", "sc1"]
AWS_CPU_CREDITS = ["standard", "unlimited"]
AWS_AZS = {
    "us-east-1": ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"],
    "us-east-2": ["us-east-2a", "us-east-2b", "us-east-2c"],
    "us-west-1": ["us-west-1a", "us-west-1b"],
    "us-west-2": ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"],
    "eu-west-1": ["eu-west-1a", "eu-west-1b", "eu-west-1c"],
    "eu-central-1": ["eu-central-1a", "eu-central-1b", "eu-central-1c"],
    "ap-south-1": ["ap-south-1a", "ap-south-1b", "ap-south-1c"],
    "ap-southeast-1": ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"],
}
AWS_PROTOCOLS = ["tcp", "udp", "icmp", "-1 (all)"]

# ═════════════════════════════════════════════════════════════════════════════
# GCP OPTIONS
# ═════════════════════════════════════════════════════════════════════════════

GCP_REGIONS = [
    "us-central1", "us-east1", "us-east4", "us-west1", "us-west2", "us-west4",
    "europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6",
    "europe-north1", "asia-east1", "asia-east2", "asia-southeast1", "asia-southeast2",
    "asia-northeast1", "asia-northeast2", "asia-south1", "australia-southeast1",
    "southamerica-east1", "northamerica-northeast1",
]

GCP_ZONES = {
    "us-central1": ["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"],
    "us-east1": ["us-east1-b", "us-east1-c", "us-east1-d"],
    "us-west1": ["us-west1-a", "us-west1-b", "us-west1-c"],
    "europe-west1": ["europe-west1-b", "europe-west1-c", "europe-west1-d"],
    "europe-west2": ["europe-west2-a", "europe-west2-b", "europe-west2-c"],
    "asia-east1": ["asia-east1-a", "asia-east1-b", "asia-east1-c"],
    "asia-southeast1": ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"],
}

GCP_MACHINE_TYPES = [
    # General Purpose — E2
    "e2-micro", "e2-small", "e2-medium",
    "e2-standard-2", "e2-standard-4", "e2-standard-8", "e2-standard-16",
    "e2-highmem-2", "e2-highmem-4", "e2-highmem-8",
    "e2-highcpu-2", "e2-highcpu-4", "e2-highcpu-8",
    # General Purpose — N2
    "n2-standard-2", "n2-standard-4", "n2-standard-8", "n2-standard-16", "n2-standard-32",
    "n2-highmem-2", "n2-highmem-4", "n2-highmem-8", "n2-highmem-16",
    "n2-highcpu-2", "n2-highcpu-4", "n2-highcpu-8", "n2-highcpu-16",
    # General Purpose — N2D
    "n2d-standard-2", "n2d-standard-4", "n2d-standard-8",
    "n2d-highmem-2", "n2d-highmem-4", "n2d-highmem-8",
    # Compute Optimized
    "c2-standard-4", "c2-standard-8", "c2-standard-16", "c2-standard-30", "c2-standard-60",
    "c2d-standard-2", "c2d-standard-4", "c2d-standard-8", "c2d-standard-16",
    # Memory Optimized
    "m1-megamem-96", "m1-ultramem-40", "m1-ultramem-80", "m1-ultramem-160",
    # GPU
    "a2-highgpu-1g", "a2-highgpu-2g", "a2-highgpu-4g",
]

GCP_IMAGES = {
    "Debian 12 (Bookworm)":     "debian-cloud/debian-12",
    "Debian 11 (Bullseye)":     "debian-cloud/debian-11",
    "Ubuntu 24.04 LTS":         "ubuntu-os-cloud/ubuntu-2404-lts",
    "Ubuntu 22.04 LTS":         "ubuntu-os-cloud/ubuntu-2204-lts",
    "Ubuntu 20.04 LTS":         "ubuntu-os-cloud/ubuntu-2004-lts",
    "CentOS Stream 9":          "centos-cloud/centos-stream-9",
    "Red Hat Enterprise Linux 9":"rhel-cloud/rhel-9",
    "Red Hat Enterprise Linux 8":"rhel-cloud/rhel-8",
    "SUSE Linux Enterprise 15": "suse-cloud/sles-15",
    "Rocky Linux 9":            "rocky-linux-cloud/rocky-linux-9",
    "Windows Server 2022":      "windows-cloud/windows-2022",
    "Windows Server 2019":      "windows-cloud/windows-2019",
    "Custom image (enter manually)": "",
}

GCP_DISK_TYPES = ["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme"]
GCP_PROTOCOLS = ["tcp", "udp", "icmp", "all"]

# ═════════════════════════════════════════════════════════════════════════════
# AZURE OPTIONS
# ═════════════════════════════════════════════════════════════════════════════

AZURE_LOCATIONS = [
    "eastus", "eastus2", "westus", "westus2", "westus3",
    "centralus", "northcentralus", "southcentralus",
    "westeurope", "northeurope", "uksouth", "ukwest",
    "francecentral", "germanywestcentral", "switzerlandnorth",
    "eastasia", "southeastasia", "japaneast", "japanwest",
    "australiaeast", "australiasoutheast",
    "koreacentral", "centralindia", "southindia",
    "canadacentral", "canadaeast", "brazilsouth",
    "uaenorth", "southafricanorth",
]

AZURE_VM_SIZES = [
    # General Purpose — B series (burstable)
    "Standard_B1s", "Standard_B1ms", "Standard_B2s", "Standard_B2ms",
    "Standard_B4ms", "Standard_B8ms", "Standard_B12ms", "Standard_B16ms",
    # General Purpose — D series
    "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3",
    "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5",
    "Standard_D2as_v5", "Standard_D4as_v5", "Standard_D8as_v5",
    # Compute Optimized — F series
    "Standard_F2s_v2", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2",
    # Memory Optimized — E series
    "Standard_E2s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3",
    "Standard_E2s_v5", "Standard_E4s_v5", "Standard_E8s_v5",
    # Storage Optimized
    "Standard_L8s_v3", "Standard_L16s_v3", "Standard_L32s_v3",
    # GPU
    "Standard_NC6s_v3", "Standard_NC12s_v3", "Standard_NC24s_v3",
    "Standard_NV6ads_A10_v5", "Standard_NV12ads_A10_v5",
]

AZURE_IMAGES = {
    "Ubuntu 24.04 LTS":           {"publisher": "Canonical", "offer": "ubuntu-24_04-lts", "sku": "server"},
    "Ubuntu 22.04 LTS":           {"publisher": "Canonical", "offer": "0001-com-ubuntu-server-jammy", "sku": "22_04-lts"},
    "Ubuntu 20.04 LTS":           {"publisher": "Canonical", "offer": "0001-com-ubuntu-server-focal", "sku": "20_04-lts"},
    "Red Hat Enterprise Linux 9":  {"publisher": "RedHat", "offer": "RHEL", "sku": "9-lvm"},
    "Red Hat Enterprise Linux 8":  {"publisher": "RedHat", "offer": "RHEL", "sku": "8-lvm"},
    "SUSE Linux Enterprise 15":    {"publisher": "SUSE", "offer": "sles-15-sp5", "sku": "gen2"},
    "CentOS Stream 9":            {"publisher": "OpenLogic", "offer": "CentOS-Stream", "sku": "9-gen2"},
    "Debian 12":                   {"publisher": "Debian", "offer": "debian-12", "sku": "12"},
    "Windows Server 2022":         {"publisher": "MicrosoftWindowsServer", "offer": "WindowsServer", "sku": "2022-datacenter"},
    "Windows Server 2019":         {"publisher": "MicrosoftWindowsServer", "offer": "WindowsServer", "sku": "2019-datacenter"},
    "Custom image (enter manually)": {"publisher": "", "offer": "", "sku": ""},
}

AZURE_STORAGE_TYPES = ["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS"]
AZURE_PROTOCOLS = ["Tcp", "Udp", "Icmp", "*"]
AZURE_ACCESS = ["Allow", "Deny"]

# ═════════════════════════════════════════════════════════════════════════════
# COMMON
# ═════════════════════════════════════════════════════════════════════════════

ENVIRONMENTS = ["production", "staging", "development", "testing", "qa"]
OS_TYPES = ["Linux", "Windows"]
DIRECTIONS = ["inbound", "outbound"]
ACCESS_TYPES = ["server", "database"]
STORAGE_SIZES = [8, 16, 20, 30, 50, 100, 200, 250, 500, 1000, 2000]


# ═════════════════════════════════════════════════════════════════════════════
# FORM RENDERERS
# ═════════════════════════════════════════════════════════════════════════════

def render_server_form(cloud: str) -> dict | None:
    """Render the server provisioning form. Returns template_inputs or None if not submitted."""

    st.markdown("### 🖥️ Server Provisioning")

    if cloud == "aws":
        return _aws_server_form()
    elif cloud == "gcp":
        return _gcp_server_form()
    elif cloud == "azure":
        return _azure_server_form()
    return None


def render_firewall_form(cloud: str) -> dict | None:
    """Render the firewall rules form."""
    st.markdown("### 🔥 Firewall Rules")

    if cloud == "aws":
        return _aws_firewall_form()
    elif cloud == "gcp":
        return _gcp_firewall_form()
    elif cloud == "azure":
        return _azure_firewall_form()
    return None


def render_permissions_form(cloud: str) -> dict | None:
    """Render the user permissions form."""
    st.markdown("### 🔐 User Permissions")

    if cloud == "aws":
        return _aws_permissions_form()
    elif cloud == "gcp":
        return _gcp_permissions_form()
    elif cloud == "azure":
        return _azure_permissions_form()
    return None


# ─────────────────────────────────────────────────────────────────────────────
# AWS FORMS
# ─────────────────────────────────────────────────────────────────────────────

def _aws_server_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        hostname = st.text_input("🏷️ Hostname (resource name)", placeholder="web-server-prod", key="aws_hostname")
        instance_type = st.selectbox("📦 Instance Type", AWS_INSTANCE_TYPES, index=2, key="aws_instance_type")
        region = st.selectbox("🌍 Region", AWS_REGIONS, key="aws_region")
        azs = AWS_AZS.get(region, [f"{region}a", f"{region}b", f"{region}c"])
        az = st.selectbox("📍 Availability Zone", azs, key="aws_az")
        storage_size = st.selectbox("💾 Root Volume Size (GB)", STORAGE_SIZES, index=4, key="aws_storage_size")

    with col2:
        ami_label = st.selectbox("🖼️ OS / AMI", list(AWS_AMIS.keys()), key="aws_ami_label")
        ami_id = AWS_AMIS[ami_label]
        if not ami_id:
            ami_id = st.text_input("Enter AMI ID", placeholder="ami-0abcdef1234567890", key="aws_custom_ami")
        os_type = st.selectbox("🖥️ OS Type", OS_TYPES, key="aws_os_type")
        storage_type = st.selectbox("💿 Volume Type", AWS_STORAGE_TYPES, key="aws_storage_type")
        cpu_credits = st.selectbox("⚡ CPU Credits", AWS_CPU_CREDITS, key="aws_cpu_credits")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="aws_env")

    st.divider()

    with st.expander("🔧 Advanced Options"):
        adv1, adv2 = st.columns(2)
        with adv1:
            vpc_id = st.text_input("🔗 VPC ID", placeholder="vpc-xxxxxxxx", key="aws_vpc")
            subnet_id = st.text_input("🔗 Subnet ID", placeholder="subnet-xxxxxxxx", key="aws_subnet")
            sg_id = st.text_input("🛡️ Security Group ID", placeholder="sg-xxxxxxxx", key="aws_sg")
        with adv2:
            key_pair = st.text_input("🔑 Key Pair Name", placeholder="my-keypair", key="aws_keypair")
            iam_profile = st.text_input("👤 IAM Instance Profile", placeholder="my-role", key="aws_iam")
            tags = st.text_input("🏷️ Tags (key=value, comma separated)", placeholder="env=prod, team=infra", key="aws_tags")

    st.divider()

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="aws_server_submit"):
        if not hostname:
            st.error("Hostname is required.")
            return None
        if not ami_id:
            st.error("AMI ID is required.")
            return None

        return {
            "hostname": hostname,
            "instance_type": instance_type,
            "ami_id": ami_id,
            "os_type": os_type.lower(),
            "cpu_credits": cpu_credits,
            "region": region,
            "availability_zone": az,
            "storage_size": storage_size,
            "storage_type": storage_type,
            "environment": environment,
            "vpc_id": vpc_id if vpc_id else None,
            "subnet_id": subnet_id if subnet_id else None,
            "security_group_id": sg_id if sg_id else None,
            "key_pair": key_pair if key_pair else None,
            "iam_instance_profile": iam_profile if iam_profile else None,
            "tags": tags if tags else None,
        }
    return None


def _aws_firewall_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        rule_name = st.text_input("🏷️ Rule Name", placeholder="allow-https", key="aws_fw_name")
        direction = st.selectbox("↕️ Direction", DIRECTIONS, key="aws_fw_dir")
        protocol = st.selectbox("📡 Protocol", AWS_PROTOCOLS, key="aws_fw_proto")
        if protocol != "icmp":
            port = st.text_input("🔌 Port", placeholder="443", key="aws_fw_port")
        else:
            port = ""

    with col2:
        sg_id = st.text_input("🛡️ Security Group ID", placeholder="sg-xxxxxxxx", key="aws_fw_sg")
        source_cidr = st.text_input("📥 Source CIDR", placeholder="0.0.0.0/0", value="0.0.0.0/0", key="aws_fw_source")
        if direction == "outbound":
            dest_cidr = st.text_input("📤 Destination CIDR", placeholder="0.0.0.0/0", value="0.0.0.0/0", key="aws_fw_dest")
        else:
            dest_cidr = ""
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="aws_fw_env")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="aws_fw_submit"):
        if not rule_name or not sg_id:
            st.error("Rule name and Security Group ID are required.")
            return None
        return {
            "rule_name": rule_name, "direction": direction, "protocol": protocol.split(" ")[0],
            "port": port, "security_group_id": sg_id, "source_cidr": source_cidr,
            "destination_cidr": dest_cidr, "environment": environment,
        }
    return None


def _aws_permissions_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        resource_name = st.text_input("🏷️ Policy Name", placeholder="ec2-access-policy", key="aws_perm_name")
        access_type = st.selectbox("🔓 Access Type", ACCESS_TYPES, key="aws_perm_type")
        iam_user = st.text_input("👤 IAM Username", placeholder="alice", key="aws_perm_user")

    with col2:
        account_id = st.text_input("🔢 AWS Account ID", placeholder="123456789012", key="aws_perm_acct")
        region = st.selectbox("🌍 Region", AWS_REGIONS, key="aws_perm_region")
        if access_type == "server":
            target = st.text_input("🖥️ Instance ID", placeholder="i-0abcdef1234567890", key="aws_perm_target")
        else:
            target = st.text_input("🗄️ DB Identifier", placeholder="my-rds-db", key="aws_perm_db")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="aws_perm_submit"):
        if not resource_name or not iam_user:
            st.error("Policy name and IAM user are required.")
            return None
        return {
            "resource_name": resource_name, "access_type": access_type,
            "iam_user": iam_user, "account_id": account_id,
            "region": region, "target_id": target,
        }
    return None


# ─────────────────────────────────────────────────────────────────────────────
# GCP FORMS
# ─────────────────────────────────────────────────────────────────────────────

def _gcp_server_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        hostname = st.text_input("🏷️ Instance Name", placeholder="web-server-prod", key="gcp_hostname")
        machine_type = st.selectbox("📦 Machine Type", GCP_MACHINE_TYPES, index=3, key="gcp_machine")
        region = st.selectbox("🌍 Region", GCP_REGIONS, key="gcp_region")
        zones = GCP_ZONES.get(region, [f"{region}-a", f"{region}-b", f"{region}-c"])
        zone = st.selectbox("📍 Zone", zones, key="gcp_zone")
        disk_size = st.selectbox("💾 Boot Disk Size (GB)", STORAGE_SIZES, index=3, key="gcp_disk_size")

    with col2:
        image_label = st.selectbox("🖼️ Boot Disk Image", list(GCP_IMAGES.keys()), key="gcp_image_label")
        image = GCP_IMAGES[image_label]
        if not image:
            image = st.text_input("Enter image path", placeholder="project/image-family", key="gcp_custom_image")
        os_type = st.selectbox("🖥️ OS Type", OS_TYPES, key="gcp_os_type")
        disk_type = st.selectbox("💿 Disk Type", GCP_DISK_TYPES, index=1, key="gcp_disk_type")
        network = st.text_input("🔗 Network", value="default", key="gcp_network")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="gcp_env")

    st.divider()

    with st.expander("🔧 Advanced Options"):
        adv1, adv2 = st.columns(2)
        with adv1:
            project_id = st.text_input("📁 Project ID", placeholder="my-gcp-project", key="gcp_project")
            subnet = st.text_input("🔗 Subnetwork", placeholder="default", key="gcp_subnet")
            service_account = st.text_input("👤 Service Account", placeholder="sa@project.iam.gserviceaccount.com", key="gcp_sa")
        with adv2:
            tags = st.text_input("🏷️ Network Tags (comma separated)", placeholder="http-server, https-server", key="gcp_tags")
            labels = st.text_input("🏷️ Labels (key=value, comma separated)", placeholder="env=prod, team=infra", key="gcp_labels")
            preemptible = st.checkbox("💰 Preemptible / Spot VM", key="gcp_preemptible")

    st.divider()

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="gcp_server_submit"):
        if not hostname:
            st.error("Instance name is required.")
            return None
        return {
            "hostname": hostname, "machine_type": machine_type, "image": image,
            "os_type": os_type.lower(), "zone": zone, "network": network,
            "disk_size": disk_size, "disk_type": disk_type, "environment": environment,
            "project_id": project_id if project_id else None,
            "subnet": subnet if subnet else None,
            "service_account": service_account if service_account else None,
            "tags": tags if tags else None,
            "labels": labels if labels else None,
            "preemptible": preemptible,
        }
    return None


def _gcp_firewall_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        rule_name = st.text_input("🏷️ Rule Name", placeholder="allow-https", key="gcp_fw_name")
        direction = st.selectbox("↕️ Direction", ["INGRESS", "EGRESS"], key="gcp_fw_dir")
        protocol = st.selectbox("📡 Protocol", GCP_PROTOCOLS, key="gcp_fw_proto")
        if protocol not in ("icmp", "all"):
            ports = st.text_input("🔌 Ports (comma separated)", placeholder="443, 8080", key="gcp_fw_ports")
        else:
            ports = ""

    with col2:
        network = st.text_input("🔗 Network", value="default", key="gcp_fw_network")
        source_ranges = st.text_input("📥 Source Ranges", placeholder="0.0.0.0/0", value="0.0.0.0/0", key="gcp_fw_source")
        priority = st.number_input("⚡ Priority", min_value=0, max_value=65535, value=1000, key="gcp_fw_priority")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="gcp_fw_env")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="gcp_fw_submit"):
        if not rule_name:
            st.error("Rule name is required.")
            return None
        return {
            "rule_name": rule_name, "direction": direction, "protocol": protocol,
            "ports": ports, "network": network, "source_ranges": source_ranges,
            "priority": priority, "environment": environment,
        }
    return None


def _gcp_permissions_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        resource_name = st.text_input("🏷️ Resource Name", placeholder="dev-access", key="gcp_perm_name")
        project_id = st.text_input("📁 Project ID", placeholder="my-gcp-project", key="gcp_perm_project")
        access_type = st.selectbox("🔓 Access Type", ACCESS_TYPES, key="gcp_perm_type")

    with col2:
        member = st.text_input("👤 Member", placeholder="user:alice@example.com", key="gcp_perm_member")
        role = st.text_input("🔑 Role", placeholder="roles/compute.instanceAdmin", key="gcp_perm_role")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="gcp_perm_env")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="gcp_perm_submit"):
        if not resource_name or not member:
            st.error("Resource name and member are required.")
            return None
        return {
            "resource_name": resource_name, "project_id": project_id,
            "access_type": access_type, "member": member, "role": role,
        }
    return None


# ─────────────────────────────────────────────────────────────────────────────
# AZURE FORMS
# ─────────────────────────────────────────────────────────────────────────────

def _azure_server_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        hostname = st.text_input("🏷️ VM Name", placeholder="web-server-prod", key="az_hostname")
        vm_size = st.selectbox("📦 VM Size", AZURE_VM_SIZES, index=8, key="az_vm_size")
        location = st.selectbox("🌍 Location", AZURE_LOCATIONS, key="az_location")
        resource_group = st.text_input("📁 Resource Group", placeholder="rg-prod-eastus", key="az_rg")
        disk_size = st.selectbox("💾 OS Disk Size (GB)", STORAGE_SIZES, index=4, key="az_disk_size")

    with col2:
        image_label = st.selectbox("🖼️ OS Image", list(AZURE_IMAGES.keys()), key="az_image_label")
        image = AZURE_IMAGES[image_label]
        if not image["publisher"]:
            image = {
                "publisher": st.text_input("Publisher", key="az_pub"),
                "offer": st.text_input("Offer", key="az_offer"),
                "sku": st.text_input("SKU", key="az_sku"),
            }
        os_type = st.selectbox("🖥️ OS Type", OS_TYPES, key="az_os_type")
        storage_type = st.selectbox("💿 Storage Account Type", AZURE_STORAGE_TYPES, index=1, key="az_storage_type")
        admin_username = st.text_input("👤 Admin Username", value="azureuser", key="az_admin")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="az_env")

    st.divider()

    with st.expander("🔧 Advanced Options"):
        adv1, adv2 = st.columns(2)
        with adv1:
            subscription_id = st.text_input("🔑 Subscription ID", key="az_sub")
            vnet = st.text_input("🔗 Virtual Network", placeholder="vnet-prod", key="az_vnet")
            subnet = st.text_input("🔗 Subnet", placeholder="subnet-default", key="az_subnet")
        with adv2:
            nsg = st.text_input("🛡️ Network Security Group", placeholder="nsg-prod", key="az_nsg")
            tags = st.text_input("🏷️ Tags (key=value, comma separated)", placeholder="env=prod, team=infra", key="az_tags")
            public_ip = st.checkbox("🌐 Assign Public IP", value=True, key="az_public_ip")

    st.divider()

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="az_server_submit"):
        if not hostname or not resource_group:
            st.error("VM name and resource group are required.")
            return None
        return {
            "hostname": hostname, "vm_size": vm_size, "location": location,
            "resource_group": resource_group, "publisher": image["publisher"],
            "offer": image["offer"], "sku": image["sku"],
            "os_type": os_type.lower(), "admin_username": admin_username,
            "disk_size": disk_size, "storage_type": storage_type,
            "environment": environment,
            "subscription_id": subscription_id if subscription_id else None,
            "vnet": vnet if vnet else None, "subnet": subnet if subnet else None,
            "nsg": nsg if nsg else None, "tags": tags if tags else None,
            "public_ip": public_ip,
        }
    return None


def _azure_firewall_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        rule_name = st.text_input("🏷️ Rule Name", placeholder="allow-https", key="az_fw_name")
        resource_group = st.text_input("📁 Resource Group", placeholder="rg-prod", key="az_fw_rg")
        nsg_name = st.text_input("🛡️ NSG Name", placeholder="nsg-prod", key="az_fw_nsg")
        direction = st.selectbox("↕️ Direction", ["Inbound", "Outbound"], key="az_fw_dir")

    with col2:
        protocol = st.selectbox("📡 Protocol", AZURE_PROTOCOLS, key="az_fw_proto")
        port_range = st.text_input("🔌 Port Range", placeholder="443", key="az_fw_port")
        source_cidr = st.text_input("📥 Source Address Prefix", placeholder="*", value="*", key="az_fw_source")
        dest_cidr = st.text_input("📤 Destination Address Prefix", placeholder="*", value="*", key="az_fw_dest")
        priority = st.number_input("⚡ Priority", min_value=100, max_value=4096, value=100, key="az_fw_priority")
        access = st.selectbox("✅ Access", AZURE_ACCESS, key="az_fw_access")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="az_fw_submit"):
        if not rule_name or not nsg_name or not resource_group:
            st.error("Rule name, NSG name, and resource group are required.")
            return None
        return {
            "rule_name": rule_name, "resource_group": resource_group,
            "nsg_name": nsg_name, "direction": direction, "protocol": protocol,
            "port_range": port_range, "source_prefix": source_cidr,
            "destination_prefix": dest_cidr, "priority": priority, "access": access,
        }
    return None


def _azure_permissions_form() -> dict | None:
    col1, col2 = st.columns(2)

    with col1:
        resource_name = st.text_input("🏷️ Assignment Name", placeholder="vm-access", key="az_perm_name")
        principal_id = st.text_input("👤 Principal ID (Object ID)", placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", key="az_perm_principal")
        access_type = st.selectbox("🔓 Access Type", ACCESS_TYPES, key="az_perm_type")

    with col2:
        scope = st.text_input("🔗 Scope (ARM Resource ID)", placeholder="/subscriptions/.../resourceGroups/...", key="az_perm_scope")
        role = st.text_input("🔑 Role Definition", placeholder="Virtual Machine Contributor", key="az_perm_role")
        environment = st.selectbox("🌐 Environment", ENVIRONMENTS, key="az_perm_env")

    if st.button("🚀 Generate Terraform", type="primary", use_container_width=True, key="az_perm_submit"):
        if not resource_name or not principal_id:
            st.error("Assignment name and principal ID are required.")
            return None
        return {
            "resource_name": resource_name, "principal_id": principal_id,
            "access_type": access_type, "scope": scope, "role": role,
        }
    return None


# ═════════════════════════════════════════════════════════════════════════════
# MAIN ROUTER
# ═════════════════════════════════════════════════════════════════════════════

def render_provisioning_form(cloud: str, workflow: str) -> dict | None:
    """Main entry point. Call with cloud='aws'|'gcp'|'azure' and
    workflow='server'|'firewall'|'permissions'.
    Returns template_inputs dict on submit, else None.
    """
    if workflow == "server":
        return render_server_form(cloud)
    elif workflow == "firewall":
        return render_firewall_form(cloud)
    elif workflow == "permissions":
        return render_permissions_form(cloud)
    return None
