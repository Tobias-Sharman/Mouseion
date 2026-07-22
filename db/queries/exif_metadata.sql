-- name: InsertExifMetadata :exec
INSERT INTO exif_metadata (
	object_id,
	taken_at,
	camera_make, camera_model, lens_model,
	latitude, longitude, altitude,
	iso,
	aperture_numerator, aperture_denominator,
	focal_length_numerator, focal_length_denominator,
	exposure_time_numerator, exposure_time_denominator,
	orientation
)
VALUES (
	$1,
	$2,
	$3, $4, $5,
	$6, $7, $8,
	$9,
	$10, $11,
	$12, $13,
	$14, $15,
	$16
);

-- name: GetExifMetadataByObjectID :one
SELECT
	object_id,
	taken_at,
	camera_make,
	camera_model,
	lens_model,
	latitude,
	longitude,
	altitude,
	iso,
	aperture_numerator,
	aperture_denominator,
	focal_length_numerator,
	focal_length_denominator,
	exposure_time_numerator,
	exposure_time_denominator,
	orientation
FROM exif_metadata
WHERE object_id = $1;
