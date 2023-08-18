package go_test

import (
	"testing"
)

func TestTagliatelleLinter(t *testing.T) {
	// These should pass the linter
	type foo struct {
		Field1 string `json:"field1"`
		Field2 string `json:"fieldOne"`
		Field3 string `json:"fieldONE"`
	}

	// These should not pass without comments to disable
	type bar struct {
		Field1 string `json:"Field1"`
		Field2 string `json:"field_1"`
		Field3 string `json:"FieldOne"`
		Field4 string `json:"FIELD1"`
	}

	// Temporary sanity check
	panic("testing")
}
