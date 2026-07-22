package analyse

import (
	"image"
	"os"

	_ "image/png"
)

// analysePNG extracts metadata from the PNG file at path
//
// TODO: more complete meta data reading
func analysePNG(path string) (*ImageMetadata, error) {
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
