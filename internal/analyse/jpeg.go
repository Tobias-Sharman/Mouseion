package analyse

import (
	"image"
	"os"

	_ "image/jpeg"
)

// analyseJPEG extracts metadata from the JPEG file at path
//
// TODO: extract orientation, camera make/model, lens, GPS coordinates, ISO, focal length, and aperture from EXIF data
func analyseJPEG(path string) (*ImageMetadata, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer func() { _ = file.Close() }()

	config, _, err := image.DecodeConfig(file)
	if err != nil {
		return nil, err
	}

	return &ImageMetadata{
		Width:  config.Width,
		Height: config.Height,
	}, nil
}
