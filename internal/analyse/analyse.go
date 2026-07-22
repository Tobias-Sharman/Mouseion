// Package analyse performs deeper, type-specific metadata extraction on objects based on their MIME type
package analyse

import "fmt"

// File dispatches to a format-specific analyser based on contentType and returns whatever metadata it can extract
// Content types with no analyser yet return an empty Analysis rather than an error.
func File(path string, contentType string) (*Analysis, error) {
	switch contentType {
	case "image/jpeg":
		image, err := analyseJPEG(path)
		if err != nil {
			return nil, fmt.Errorf("analyse jpeg: %w", err)
		}
		return &Analysis{Image: image}, nil

	case "image/png":
		image, err := analysePNG(path)
		if err != nil {
			return nil, fmt.Errorf("analyse png: %w", err)
		}
		return &Analysis{Image: image}, nil

	default:
		// TODO: add more analysers as new types need deeper metadata.
		return &Analysis{}, nil
	}
}
