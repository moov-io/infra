// Copyright 2018 The ACH Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

// infra (as a Go package) is a cli tool used by the
// infrastructure folks at Moov.io. Contained within
// are commands for:
//  - in-repo secret management (via https://github.com/StackExchange/blackbox)
//
// Installing this package is easy, simply go install
//   $ go install https://github.com/moov-io/infra
//
// We maintain no real guarentee of compatibility right now.
package main

import (
	"fmt"
	"flag"
	"os"
)

const Version = "v0.1.0-dev"

var (
	flagDecrypt = flag.String("decrypt", "", "(in-repo) filepath to decrypt via blackbox")
	flagEncrypt = flag.String("encrypt", "", "(in-repo) filepath to encrypt via blackbox")

	commands = []*command{
		&command{
			Activated: func() bool {
				return
			},
			Name: "",
		}
	}
)

func main() {
	flag.Parse()


}

// infra check secrets

// infra encrypt $path
// infra decrypt $path

// infra --encrypt $path

type fn func() bool

type command struct {
	// Activated should be called to determine if this command
	// should be executed or not. (i.e. checking flags)
	Activated fn
}
