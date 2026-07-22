-- name: InsertObject :one
INSERT INTO objects (sha256, collision_index, size_bytes, content_type, storage_key)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, sha256, collision_index, size_bytes, content_type, storage_key, created_at;

-- name: ListObjectsBySHA256 :many
SELECT
	id,
	sha256,
	collision_index,
	size_bytes,
	content_type,
	storage_key,
	created_at
FROM objects
WHERE sha256 = $1
ORDER BY collision_index;

-- name: GetObjectBySHA256AndCollisionIndex :one
SELECT
	id,
	sha256,
	collision_index,
	size_bytes,
	content_type,
	storage_key,
	created_at
FROM objects
WHERE sha256 = $1 AND collision_index = $2;

-- name: GetObjectByID :one
SELECT
	id,
	sha256,
	collision_index,
	size_bytes,
	content_type,
	storage_key,
	created_at
FROM objects
WHERE id = $1;

-- name: ListObjects :many
SELECT
	id,
	sha256,
	collision_index,
	size_bytes,
	content_type,
	storage_key,
	created_at
FROM objects
ORDER BY created_at DESC;
