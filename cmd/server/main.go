// Command server runs the mouseion HTTP API.
package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/Tobias-Sharman/mouseion/internal/database"
	"github.com/Tobias-Sharman/mouseion/internal/storage"
)

func main() {
	storageRoot := getEnv("STORAGE_ROOT", "./data")
	databaseURL := getEnv("DATABASE_URL", "postgres://localhost/pinakes?sslmode=disable")
	addr := getEnv("ADDR", ":8080")

	store := storage.New(storageRoot)
	if err := store.Init(); err != nil {
		log.Fatalf("initialise storage: %v", err)
	}

	pool, err := database.Connect(context.Background(), databaseURL)
	if err != nil {
		log.Fatalf("connect to database: %v", err)
	}
	defer pool.Close()

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", handleHealth)
	mux.HandleFunc("/upload", handleUpload(store, pool))

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server stopped: %v", err)
	}
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func handleHealth(response http.ResponseWriter, _ *http.Request) {
	response.WriteHeader(http.StatusOK)
}
