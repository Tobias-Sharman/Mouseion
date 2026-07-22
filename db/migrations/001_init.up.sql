CREATE TABLE objects (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

	sha256 BYTEA NOT NULL,
	collision_index INT NOT NULL DEFAULT 0,

	size_bytes BIGINT NOT NULL CHECK (size_bytes >= 0),

	content_type TEXT NOT NULL,

	storage_key TEXT NOT NULL UNIQUE,

	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

	UNIQUE (sha256, collision_index)
);

CREATE TABLE uploads (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

	filename TEXT NOT NULL,

	status TEXT NOT NULL DEFAULT 'staged' CHECK (status IN ('staged', 'analysed', 'committed', 'failed')),
	error_message TEXT,

	object_id BIGINT REFERENCES objects (id),

	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE image_metadata (
	object_id BIGINT PRIMARY KEY REFERENCES objects (id) ON DELETE CASCADE,

	width INT NOT NULL,
	height INT NOT NULL
);

CREATE TABLE exif_metadata (
	object_id BIGINT PRIMARY KEY REFERENCES objects (id) ON DELETE CASCADE,

	taken_at TIMESTAMPTZ,

	camera_make TEXT,
	camera_model TEXT,
	lens_model TEXT,

	latitude DOUBLE PRECISION,
	longitude DOUBLE PRECISION,
	altitude DOUBLE PRECISION,

	iso INT,

	aperture_numerator INT,
	aperture_denominator INT,

	focal_length_numerator INT,
	focal_length_denominator INT,

	exposure_time_numerator INT,
	exposure_time_denominator INT,

	orientation INT
);
