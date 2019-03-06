// Copyright 2019 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

// installJsonnet will install jsonnet on the host system.
//
// If this becomes a problem (to install/modify the host) we could try volume mapping a Docker
// container that generates the files (albeit slower).
func installJsonnet() error {
	log.Println("Installing jsonnet and jsonnet-bundler to your system")

	out, err := exec.Command("brew", "install", "jsonnet").CombinedOutput()
	if err != nil {
		return fmt.Errorf("ERROR installing jsonnet: %v\n\nOutput:\n%v", err, string(out))
	}

	cmd := exec.Command("go", "get", "github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb")
	cmd.Env = []string{
		fmt.Sprintf("HOME=%s", os.Getenv("HOME")),
		"GO111MODULE=off",
		fmt.Sprintf("GOPATH=%s", os.Getenv("GOPATH")),
	}
	out, err = cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("ERROR installing jsonnet-bundler: %v\n\nOutput:\n%v", err, string(out))
	}
	return nil
}

// buildMixins pulls down the kubernetes-monitoring/kubernetes-mixin source code compiles the jsonnet recipes
// to generate prometheus alerts, rules and grafana dashboards.
//
// Returned is a temp directory where the files can be found, refer to the install guide below for specific
// files created. Callers are expected to cleanup the temp directory.
//
// See: https://github.com/kubernetes-monitoring/kubernetes-mixin#generate-config-files
func buildMixins() (string, error) {
	dir, err := ioutil.TempDir("", "kubernetes-mixin")
	if err != nil {
		return dir, fmt.Errorf("ERROR building kubernetes-mixins: %v", err)
	}

	// Download source code
	cmd := exec.Command("git", "clone", "--depth=1", "https://github.com/kubernetes-monitoring/kubernetes-mixin")
	cmd.Dir = dir
	out, err := cmd.CombinedOutput()
	if err != nil {
		return dir, fmt.Errorf("ERROR cloning kubernetes-mixin source: %v\n\nOutput: %v", err, string(out))
	}

	// jb install
	cmd = exec.Command("jb", "install")
	cmd.Dir = filepath.Join(dir, "kubernetes-mixin")
	out, err = cmd.CombinedOutput()
	if err != nil {
		return dir, fmt.Errorf("ERROR preparing kubernetes-mixins: %v\n\nOutput: %v", err, string(out))
	}

	// Generate via make tasks
	mk := func(what string) error {
		cmd := exec.Command("make", what)
		cmd.Dir = filepath.Join(dir, "kubernetes-mixin")
		out, err = cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("ERROR make %s: %v", what, err)
		}
		return nil
	}
	if err := mk("prometheus_alerts.yaml"); err != nil {
		return dir, err
	}
	// if err := mk("prometheus_rules.yaml"); err != nil {
	// 	return dir, err // ignored for now
	// }
	// if err := mk("dashboards_out"); err != nil {
	// 	return dir, err // TODO(adam): upload to grafana?
	// }
	return dir, nil
}
