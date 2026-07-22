package analyse

import "time"

// ImageMetadata contains the basic dimensions of an image, present for any supported image format
type ImageMetadata struct {
	Width  int
	Height int
}

// ExifMetadata contains metadata of interest extracted from an image's EXIF block, where present
type ExifMetadata struct {
	TakenAt *time.Time

	CameraMake  *string
	CameraModel *string
	LensModel   *string

	Latitude  *float64
	Longitude *float64
	Altitude  *float64

	ISO *int

	ApertureNumerator   *int
	ApertureDenominator *int

	FocalLengthNumerator   *int
	FocalLengthDenominator *int

	ExposureTimeNumerator   *int
	ExposureTimeDenominator *int

	Orientation *int
}

// Analysis contains type specific metadata
type Analysis struct {
	Image *ImageMetadata
	Exif  *ExifMetadata
}
