-- name: CreateUpload :one
INSERT INTO uploads (filename)
VALUES ($1)
RETURNING id, filename, status, error_message, object_id, created_at, updated_at;

-- name: MarkUploadAnalysed :execrows
UPDATE uploads
SET status = 'analysed', object_id = $2, updated_at = NOW()
WHERE id = $1;

-- name: MarkUploadCommitted :execrows
UPDATE uploads
SET status = 'committed', updated_at = NOW()
WHERE id = $1;

-- name: MarkUploadFailed :execrows
UPDATE uploads
SET status = 'failed', error_message = $2, updated_at = NOW()
WHERE id = $1;

-- name: GetUploadByID :one
SELECT
	id,
	filename,
	status,
	error_message,
	object_id,
	created_at,
	updated_at
FROM uploads
WHERE id = $1;

-- name: ListUploads :many
SELECT
	id,
	filename,
	status,
	error_message,
	object_id,
	created_at,
	updated_at
FROM uploads
ORDER BY created_at DESC;
