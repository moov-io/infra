package code

import (
	"math/rand/v2"
)

func randomFrom2[T any](items ...T) T {
	if len(items) == 0 {
		var zero T
		return zero
	}

	return items[rand.IntN(len(items))]
}
