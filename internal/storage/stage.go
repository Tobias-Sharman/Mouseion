package storage

import (
	"crypto/sha256"
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/Tobias-Sharman/mouseion/internal/upload"
)

// Stage takes in a file reading its base information and writes it to the temporary staging directory
//   - computes its SHA-256 hash, size, and sniffed MIME type as it streams through
func (storage *Storage) Stage(incoming upload.Upload) (*StagedUpload, error) {
	tmpFile, err := os.CreateTemp(storage.tmpPath, "upload-*")
	if err != nil {
		return nil, fmt.Errorf("create temp file: %w", err)
	}
	defer func() { _ = tmpFile.Close() }()

	hasher := sha256.New()
	destination := io.MultiWriter(tmpFile, hasher)

	sniffBuffer := make([]byte, 512)
	read, err := io.ReadFull(incoming.Reader, sniffBuffer)
	if err != nil && err != io.ErrUnexpectedEOF && err != io.EOF {
		return nil, fmt.Errorf("read upload: %w", err)
	}
	sniffBuffer = sniffBuffer[:read]
	mimeType := http.DetectContentType(sniffBuffer)

	_, err = destination.Write(sniffBuffer)
	if err != nil {
		return nil, fmt.Errorf("write staged file: %w", err)
	}
	size := int64(read)

	written, err := io.Copy(destination, incoming.Reader)
	if err != nil {
		return nil, fmt.Errorf("write staged file: %w", err)
	}
	size += written

	var digest [32]byte
	copy(digest[:], hasher.Sum(nil))

	return &StagedUpload{
		Filename:  incoming.Filename,
		Path:      tmpFile.Name(),
		SHA256:    digest,
		SizeBytes: size,
		MimeType:  mimeType,
	}, nil
}
