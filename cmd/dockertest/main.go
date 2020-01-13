// Copyright 2020 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

// dockertest is a quick cli tool used to test docker image building in relative directories
//
// This tool looks for a directory called images/ which has directories (one for each image)
// inside. Then each docker image is expected to have a GNU makefile that supports 'make docker'.
//
// Builds are ran concurrently to each other and errors are reported to stdout.
//
// dockertest is not a stable tool. Please contact Moov developers if you intend to use this tool,
// otherwise we might change the tool (or remove it) without notice.
package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sync"
)

var (
	flagVerbose = flag.Bool("verbose", false, "Verbose: show all log output")
)

func main() {
	flag.Parse()

	if !dockerEnabled() {
		log.Printf("Docker is not enabled on %s, quitting...", runtime.GOOS)
		return
	}

	// Verify we are in the root of infra/
	parent, err := os.Getwd()
	if dir := filepath.Base(parent); dir != "infra" || parent == "" {
		log.Fatalf("ERROR: unknown directory 'dockertest' is ran from: %s", dir)
	}
	parent = filepath.Join(parent, "images")

	// read directories
	fds, err := ioutil.ReadDir(parent)
	if err != nil {
		log.Printf("ERROR: reading directory %s - %v", parent, err)
	}

	// test each directory
	t := &tester{}
	t.wg.Add(len(fds))
	for i := range fds {
		go t.run(fds[i].Name(), parent)
	}
	t.wg.Wait()
	if len(t.errors) > 0 {
		os.Exit(1)
	} else {
		log.Println("SUCCESS all docker tests passed")
	}
}

func dockerEnabled() bool {
	out, err := exec.Command("docker", "ps").CombinedOutput()
	if err == nil {
		return true // worked, so we have docker
	}
	if err != nil || bytes.Contains(out, []byte("Cannot connect to the Docker daemon")) {
		return false
	}
	// Docker creates '.dockerenv' in the FS root, so if we see that
	// declare docker is disabled (avoid docker-in-docker)
	_, err = os.Stat("/.dockerenv")
	return err == nil // file must exist
}

type tester struct {
	wg     sync.WaitGroup
	errors []error
}

func (t *tester) run(name string, parent string) {
	defer t.wg.Done()

	log.Printf("building docker image and running %s tests", name)

	cmd := exec.Command("make", "docker")
	cmd.Dir = filepath.Join(parent, name)
	bs, err := cmd.CombinedOutput()

	if *flagVerbose || err != nil {
		fmt.Printf("\n%s docker build output:\n%s\n\n", name, string(bs))
	}
	if err != nil {
		err = fmt.Errorf("ERROR running %s tests: %v", name, err)
		t.errors = append(t.errors, err)
		log.Printf("ERROR %v\n", err.Error())
	} else {
		log.Printf("SUCCESS %s image built and tests passed", name)
	}
}
