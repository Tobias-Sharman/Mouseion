# Mouseion

A personal cloud storage service: uploads get staged, analysed (hash, MIME type,
and format-specific metadata), deduplicated by content hash, persisted to
Postgres, and moved into permanent content-addressed storage.

## Local development (no docker)

No current proper build and install script, so Postgres (via Homebrew),
`golang-migrate`, and `sqlc` are required to be installed locally. Once a good
first version is in place such scripts will be provided.

```bash
./scripts/setup.sh   # start postgres, create db, run migrations, sqlc generate,
create data dirs
./scripts/start.sh   # start postgres, run migrations, go run ./cmd/server
./scripts/stop.sh    # stop postgres

curl http://localhost:8080/healthz
curl -F file=@path/to/file.jpg http://localhost:8080/upload
```

## Running with Docker

```bash
docker compose up --build
```

Spins up Postgres, runs migrations via a one-shot `migrate` container, then
starts the app on `:8080`.

**Before running this anywhere beyond a local/VM dev environment:**
`compose.yaml` uses placeholder Postgres credentials (`pinakes`/`pinakes`).
Postgres itself isn't exposed outside the Docker network (no `ports:` mapping on
`db`), so this is low-risk as a dev setup, but these credentials should be
replaced before any real deployment.

```bash
curl http://<host>:8080/healthz
curl -F file=@test-files/test_file_00001.jpg http://<host>:8080/upload
```

## Naming

This project follows a Library of Alexandria theme (as seen similarly in
[Pharos][https://github.com/Tobias-Sharman/Pharos]):

- **Mouseion** — the overall project/service, spanning both sites below
- **Serapeum** — the AWS-hosted site (provisioned via Terraform)
- **Alex** — the home-hosted site

## Architecture

The end goal intention is that Alex runs the primary cluster day to day —
control plane, storage, and the web tier all live at home to keep ongoing costs
low. Serapeum stays minimal under normal operation: a reverse proxy hiding
Alex's IP and absorbing any traffic issues and concealing personal ip as a
personal exposure preference, plus a health check watching Alex's availability.

If Alex goes down, Serapeum's health check triggers the same Terraform +
Ansible automation used to build the cluster in the first place, standing up
a temporary control plane in AWS and restoring application state from
periodic S3 backups. This is a cold-standby failover, not live replication —
so recovery will not be instant and will take a noticeable amount of time, for
cost related reasons this is acceptable. A less cost centric model would be
more suited to use a single control plane based in the cloud and have the
worker nodes split per usage intention for reasons related to data storage
location or possible further cost related reasons that are distinct from the
controllers, e.g. more intensive loads you have hardware intended for.

Not every workload participates in failover: home-automation nodes would be
pinned to Alex only (there's no cloud equivalent for physical home hardware)
and simply go offline during an Alex outage, by design. For stuff that is cloud
based and would want clean migration to the temporary mock up in the cloud on
failure of the home site then this stuff would be handled similarly to the entry
point DNS-failover for the API server, with then certs likely backed up to S3
for this.

## Future plans

In no particular order:

- Redownload functionality
- Limit files to a user but allow for deduplication for duplicate files across
users
    - Shared libraries too
- Web portal for access easy access
- Thumbnail generation
- Image recognition
- A more aggressive optimised storage via metadata stripping and/or compression
for an archival storage
- Custom redis cache
- See images by location on a map
- Search index
- Media streaming
- File version control
- Dashboard & metrics
- File storage sync

### Server but not cloud storage plans

Plans not directly relevant to the cloud storage but for a home server, which
this project will later, likely, encompass.

- Vpn
- Reverse proxy
- Ad/tracker blocking, and other general network management
- Smart home management - not through an existing solution but an exploration
into hardware interaction
