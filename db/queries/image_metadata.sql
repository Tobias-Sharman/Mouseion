-- name: InsertImageMetadata :exec
INSERT INTO image_metadata (object_id, width, height)
VALUES ($1, $2, $3);

-- name: GetImageMetadataByObjectID :one
SELECT
	object_id,
	width,
	height
FROM image_metadata
WHERE object_id = $1;
