package code

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestReflectCall(t *testing.T) {
	var buf bytes.Buffer
	reflectCall(&buf)

	require.Equal(t, "add(5, 3) = 8", buf.String())
}
