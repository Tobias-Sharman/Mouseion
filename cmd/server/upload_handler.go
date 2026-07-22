package main

import (
	"log"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Tobias-Sharman/mouseion/internal/ingest"
	"github.com/Tobias-Sharman/mouseion/internal/storage"
	"github.com/Tobias-Sharman/mouseion/internal/upload"
)

// handleUpload accepts a single multipart file upload and runs it through the ingest pipeline
//
// TODO: proper structured error responses, upload size limits, auth, and multi-file support all still need adding
func handleUpload(store *storage.Storage, pool *pgxpool.Pool) http.HandlerFunc {
	return func(response http.ResponseWriter, request *http.Request) {
		file, header, err := request.FormFile("file")
		if err != nil {
			http.Error(response, "missing file", http.StatusBadRequest)
			return
		}
		defer func() { _ = file.Close() }()

		incoming := upload.Upload{
			Filename:    header.Filename,
			ContentType: header.Header.Get("Content-Type"),
			Reader:      file,
		}

		result, err := ingest.File(request.Context(), pool, store, incoming)
		if err != nil {
			log.Printf("ingest failed: %v", err)
			http.Error(response, "ingest failed", http.StatusInternalServerError)
			return
		}

		log.Printf("ingested %q -> %s", result.StagedUpload.Filename, result.StorageKey)
		response.WriteHeader(http.StatusCreated)
	}
}
