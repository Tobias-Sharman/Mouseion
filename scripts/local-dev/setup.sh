#!/usr/bin/env bash
set -euo pipefail

DB_NAME="pinakes"

echo "Starting PostgreSQL..."
pg_ctl -D "$(brew --prefix)/var/postgresql@18" start

echo "Creating database..."
createdb "$DB_NAME" 2>/dev/null || true

echo "Running migrations..."
migrate \
	-path db/migrations \
	-database "postgres://localhost/${DB_NAME}?sslmode=disable" \
	up

echo "Generating sqlc..."
sqlc generate

echo "Creating storage directories..."
mkdir -p data/tmp/uploads data/objects

echo "Stopping PostgreSQL..."
pg_ctl -D "$(brew --prefix)/var/postgresql@18" stop

echo "Setup complete."
