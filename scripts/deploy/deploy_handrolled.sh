#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/terraform"
ANSIBLE_DIR="$REPO_ROOT/ansible"

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }
ok() { printf "\033[1;32m==>\033[0m %s\n" "$1"; }

run_playbook() {
	info "Running $1..."
	(cd "$ANSIBLE_DIR" && ansible-playbook -i inventory.aws_ec2.yml "playbooks/$1")
}

# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------

info "Applying Terraform..."
(cd "$TERRAFORM_DIR" && terraform apply)
ok "Terraform apply complete."

# -----------------------------------------------------------------------------
# Wait for the VPN gateway to accept SSH
# -----------------------------------------------------------------------------

VPN_IP="$(cd "$TERRAFORM_DIR" && terraform output -raw vpn_public_ip)"
info "Waiting for VPN gateway ($VPN_IP) to accept SSH..."
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "admin@$VPN_IP" true 2>/dev/null; do
	sleep 5
done
ok "VPN gateway reachable."

# -----------------------------------------------------------------------------
# Bootstrap the VPN gateway (public SSH, doesn't need the tunnel)
# -----------------------------------------------------------------------------

run_playbook 01_vpn_gateway.yml

# -----------------------------------------------------------------------------
# Manual step: bring up the local WireGuard tunnel
# -----------------------------------------------------------------------------

warn "Manual step required: bring up your local WireGuard tunnel now."
warn "Client config: $ANSIBLE_DIR/wireguard/admin-laptop.conf"
warn "e.g. sudo wg-quick up $ANSIBLE_DIR/wireguard/admin-laptop.conf"
read -r -p "Press enter once the tunnel is up and confirmed working... " _

# -----------------------------------------------------------------------------
# Certs, kubeconfigs, encryption config (local-only, no SSH needed)
# -----------------------------------------------------------------------------

run_playbook 02_certs.yml
run_playbook 03_kubeconfigs.yml
run_playbook 04_encryption_config.yml

# -----------------------------------------------------------------------------
# etcd and control plane (need the tunnel - private subnet SSH)
# -----------------------------------------------------------------------------

run_playbook 05_etcd.yml
run_playbook 06_control_plane.yml

# -----------------------------------------------------------------------------
# Worker bootstrap and CoreDNS
# -----------------------------------------------------------------------------

run_playbook 07_worker_bootstrap.yml
run_playbook 08_coredns.yml

ok "Cluster deployment complete."
warn "This is the v1 hand-rolled build: infrastructure only, no Mouseion application deployed."
warn "v1 gets no further updates - the app, and any further changes, land on v2 (kubeadm-based)."
echo
echo "Verify with:"
echo "  KUBECONFIG=$ANSIBLE_DIR/certs/admin.kubeconfig kubectl get nodes -o wide"
