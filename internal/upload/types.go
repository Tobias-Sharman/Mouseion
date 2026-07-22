// Package upload holds the interaction for uploaded files
package upload

import "io"

// Upload represents an incoming file before it has been staged to disk
type Upload struct {
	Filename    string
	ContentType string
	Reader      io.Reader
}
