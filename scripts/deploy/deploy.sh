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
	(cd "$ANSIBLE_DIR" && ansible-playbook "playbooks/$1")
}

# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------

info "Applying Terraform..."
terraform -chdir="$TERRAFORM_DIR" init -input=false >/dev/null
terraform -chdir="$TERRAFORM_DIR" apply
ok "Terraform apply complete."

# -----------------------------------------------------------------------------
# Gateway (public SSH, doesn't need the tunnel, the playbook waits for it to boot)
# -----------------------------------------------------------------------------

(cd "$ANSIBLE_DIR" && ansible-galaxy collection install -r requirements.yml >/dev/null)
run_playbook 01_gateway.yml

# -----------------------------------------------------------------------------
# Manual step: bring up the local WireGuard tunnel
# -----------------------------------------------------------------------------

warn "Manual step required: bring up your local WireGuard tunnel now, e.g."
warn "  sudo wg-quick up $ANSIBLE_DIR/wireguard/admin-laptop.conf"
read -r -p "Press enter once the tunnel is up... " _

# -----------------------------------------------------------------------------
# Nodes (private subnet, only reachable through the tunnel)
# -----------------------------------------------------------------------------

info "Checking every node is reachable through the tunnel..."
(cd "$ANSIBLE_DIR" && ansible node -m ansible.builtin.ping)
ok "Infrastructure ready."
echo
terraform -chdir="$TERRAFORM_DIR" output node_private_ips
echo "SSH via the tunnel with: ssh admin@<node private ip>"
echo "Tear down with: terraform -chdir=$TERRAFORM_DIR destroy"
