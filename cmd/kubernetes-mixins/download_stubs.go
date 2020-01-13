// Copyright 2020 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

// +build !darwin

package main

import (
	"fmt"
	"runtime"
)

func installJsonnet() error {
	return fmt.Errorf("installing jsonnet unsupported on %s", runtime.GOOS)
}

func buildMixins() (string, error) {
	return "", fmt.Errorf("building kuberntes-mixins unsupported on %s", runtime.GOOS)
}
