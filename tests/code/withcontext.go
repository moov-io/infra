package code

import (
	"context"
	"database/sql"
	"fmt"
)

type Env struct {
	DB       *sql.DB
	Shutdown func()
}

func withcontext(ctx context.Context, env *Env) error {
	db, close, err := initDatabase(ctx, env)
	if err != nil {
		return fmt.Errorf("creating database: %w", err)
	}

	prev := env.Shutdown
	env.Shutdown = func() {
		if prev != nil {
			prev()
		}
		if close != nil {
			close()
		}
	}

	env.DB = db

	return nil
}

func initDatabase(ctx context.Context, env *Env) (*sql.DB, func(), error) {
	_, cancelFunc := context.WithCancel(ctx)

	db, err := sql.Open("sqlite", "testing")
	if err != nil {
		cancelFunc()
		return nil, cancelFunc, fmt.Errorf("opening database: %w", err)
	}
	return db, cancelFunc, nil
}
