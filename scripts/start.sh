#!/usr/bin/env bash
set -euo pipefail

DB_NAME="pinakes"

echo "Starting PostgreSQL..."
pg_ctl -D "$(brew --prefix)/var/postgresql@18" start

echo "Running migrations..."
migrate \
	-path db/migrations \
	-database "postgres://localhost/${DB_NAME}?sslmode=disable" \
	up

echo "Starting application..."
go run ./cmd/server
