# Mouseion

A personal cloud storage service: uploads get staged, analysed (hash, MIME type, and format-specific metadata), deduplicated by content hash, persisted to Postgres, and moved into permanent content-addressed storage.

## Local development

No current proper build and install script, so Postgres (via Homebrew), `golang-migrate`, and `sqlc` are required to be installed locally. Once a good first version is in place such scripts will be provided.

```bash
./scripts/setup.sh   # start postgres, create db, run migrations, sqlc generate, create data dirs
./scripts/start.sh   # start postgres, run migrations, go run ./cmd/server
./scripts/stop.sh    # stop postgres

curl http://localhost:8080/healthz
curl -F file=@path/to/file.jpg http://localhost:8080/upload
```

## Future plans

In no particular order:

- Redownload functionality
- Limit files to a user but allow for deduplication for duplicate files across users
    - Shared libraries too
- Web portal for access easy access
- Thumbnail generation
- Image recognition
- A more aggressive optimised storage via metadata stripping and/or compression for an archival storage
- Custom redis cache
- See images by location on a map
- Search index
- Media streaming
- File version control
- Dashboard & metrics
- File storage sync

### Server but not cloud storage plans

Plans not directly relevant to the cloud storage but for a home server, which this project will later, likely, encompass.

- Vpn
- Reverse proxy
- Ad/tracker blocking, and other general network management
- Smart home management - not through an existing solution but an exploration into hardware interaction
