// Package storage handles staging, writing, and movement of uploaded files on disk
package storage

import "path/filepath"

// New creates a Storage rooted at the given directory
//   - Call Init before using it to ensure the required subdirectories exist
func New(root string) *Storage {
	return &Storage{
		root:        root,
		tmpPath:     filepath.Join(root, "tmp", "uploads"),
		objectsPath: filepath.Join(root, "objects"),
	}
}
