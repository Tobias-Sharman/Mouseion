package storage

// Storage manages the on-disk layout for uploaded objects:
//   - a temporary staging area for files still being written
//   - and permanent content-addressed storage for files that have been committed
type Storage struct {
	root        string
	tmpPath     string
	objectsPath string
}

// StagedUpload is the result of writing an incoming upload to the temporary staging directory
//   - Read full file information and get the MimeType so it can be passed off to the appropriate analyser
type StagedUpload struct {
	Filename string

	Path string

	SHA256    [32]byte
	SizeBytes int64
	MimeType  string
}
