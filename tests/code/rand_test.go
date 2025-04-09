package code_test

import (
	"math/rand"
	"time"
)

func foo_rand() {
	rand.Seed(time.Now().Unix())
}
