// Package ingest wires together the ingest pipeline
package ingest

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Tobias-Sharman/mouseion/internal/analyse"
	"github.com/Tobias-Sharman/mouseion/internal/database/sqlcgen"
	"github.com/Tobias-Sharman/mouseion/internal/storage"
	"github.com/Tobias-Sharman/mouseion/internal/upload"
)

// Result is the outcome of ingesting a single upload
type Result struct {
	UploadID     int64
	StagedUpload *storage.StagedUpload
	Analysis     *analyse.Analysis
	ObjectID     int64
	StorageKey   string
}

// File runs an upload through the full ingest pipeline
func File(ctx context.Context, pool *pgxpool.Pool, store *storage.Storage, incoming upload.Upload) (*Result, error) {
	queries := sqlcgen.New(pool)

	uploadRow, err := queries.CreateUpload(ctx, incoming.Filename)
	if err != nil {
		return nil, fmt.Errorf("create upload record: %w", err)
	}

	result, err := run(ctx, queries, store, incoming, uploadRow.ID)
	if err != nil {
		_, _ = queries.MarkUploadFailed(ctx, sqlcgen.MarkUploadFailedParams{
			ID:           uploadRow.ID,
			ErrorMessage: pgtype.Text{String: err.Error(), Valid: true},
		})
		return nil, err
	}

	return result, nil
}

func run(ctx context.Context, queries *sqlcgen.Queries, store *storage.Storage, incoming upload.Upload, uploadID int64) (*Result, error) {
	staged, err := store.Stage(incoming)
	if err != nil {
		return nil, fmt.Errorf("stage upload: %w", err)
	}

	analysis, err := analyse.File(staged.Path, staged.MimeType)
	if err != nil {
		return nil, fmt.Errorf("analyse upload: %w", err)
	}

	object, isNew, err := resolveObject(ctx, queries, store, staged)
	if err != nil {
		return nil, fmt.Errorf("resolve object: %w", err)
	}

	if isNew {
		if err := persistMetadata(ctx, queries, object.ID, analysis); err != nil {
			return nil, fmt.Errorf("persist metadata: %w", err)
		}
	}

	if _, err := queries.MarkUploadAnalysed(ctx, sqlcgen.MarkUploadAnalysedParams{
		ID:       uploadID,
		ObjectID: pgtype.Int8{Int64: object.ID, Valid: true},
	}); err != nil {
		return nil, fmt.Errorf("mark upload analysed: %w", err)
	}

	if isNew {
		if err := store.Commit(staged, object.StorageKey); err != nil {
			return nil, fmt.Errorf("commit upload: %w", err)
		}
	} else {
		if err := os.Remove(staged.Path); err != nil {
			return nil, fmt.Errorf("discard duplicate staged file: %w", err)
		}
	}

	if _, err := queries.MarkUploadCommitted(ctx, uploadID); err != nil {
		return nil, fmt.Errorf("mark upload committed: %w", err)
	}

	return &Result{
		UploadID:     uploadID,
		StagedUpload: staged,
		Analysis:     analysis,
		ObjectID:     object.ID,
		StorageKey:   object.StorageKey,
	}, nil
}

func resolveObject(ctx context.Context, queries *sqlcgen.Queries, store *storage.Storage, staged *storage.StagedUpload) (sqlcgen.Object, bool, error) {
	existing, err := queries.ListObjectsBySHA256(ctx, staged.SHA256[:])
	if err != nil {
		return sqlcgen.Object{}, false, fmt.Errorf("list objects by hash: %w", err)
	}

	for _, candidate := range existing {
		// TODO: Full byte comparison
		if candidate.SizeBytes == staged.SizeBytes && candidate.ContentType == staged.MimeType {
			return candidate, false, nil
		}
	}

	collisionIndex := int32(len(existing))
	key := store.ObjectKey(staged.SHA256, int(collisionIndex))

	object, err := queries.InsertObject(ctx, sqlcgen.InsertObjectParams{
		Sha256:         staged.SHA256[:],
		CollisionIndex: collisionIndex,
		SizeBytes:      staged.SizeBytes,
		ContentType:    staged.MimeType,
		StorageKey:     key,
	})
	if err != nil {
		return sqlcgen.Object{}, false, fmt.Errorf("insert object: %w", err)
	}

	return object, true, nil
}

func persistMetadata(ctx context.Context, queries *sqlcgen.Queries, objectID int64, analysis *analyse.Analysis) error {
	if analysis.Image != nil {
		if err := queries.InsertImageMetadata(ctx, sqlcgen.InsertImageMetadataParams{
			ObjectID: objectID,
			Width:    int32(analysis.Image.Width),
			Height:   int32(analysis.Image.Height),
		}); err != nil {
			return fmt.Errorf("insert image metadata: %w", err)
		}
	}

	// TODO: EXIF
	return nil
}
