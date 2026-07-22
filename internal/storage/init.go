package storage

import "os"

// Init creates the directories Storage needs (staging and objects)
func (storage *Storage) Init() error {
	directories := []string{
		storage.tmpPath,
		storage.objectsPath,
	}

	for _, directory := range directories {
		if err := os.MkdirAll(directory, 0o700); err != nil {
			return err
		}
	}

	return nil
}
