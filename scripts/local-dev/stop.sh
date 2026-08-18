#!/usr/bin/env bash
set -euo pipefail

echo "Stopping PostgreSQL..."
pg_ctl -D "$(brew --prefix)/var/postgresql@18" stop

echo "Done."
