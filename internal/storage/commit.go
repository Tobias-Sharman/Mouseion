package storage

import (
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
)

// ObjectKey returns the storage key for a given hash and collision index
func (storage *Storage) ObjectKey(sha256 [32]byte, collisionIndex int) string {
	digest := hex.EncodeToString(sha256[:])
	return filepath.Join(digest[:2], digest[2:4], digest, strconv.Itoa(collisionIndex))
}

// Commit moves a staged upload from the temporary staging directory into permanent storage at the given key
func (storage *Storage) Commit(staged *StagedUpload, key string) error {
	destination := filepath.Join(storage.objectsPath, key)
	if err := os.MkdirAll(filepath.Dir(destination), 0o700); err != nil {
		return fmt.Errorf("create object directory: %w", err)
	}

	if err := os.Rename(staged.Path, destination); err != nil {
		return fmt.Errorf("move staged file into storage: %w", err)
	}

	return nil
}
