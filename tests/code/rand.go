package code

import (
	"math/rand"
)

func randomFrom[T any](items ...T) T {
	if len(items) == 0 {
		var zero T
		return zero
	}

	return items[rand.Intn(len(items))] //nolint:forbidigo
}
