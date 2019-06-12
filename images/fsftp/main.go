// Copyright 2019 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

package main

import (
	"flag"
	"log"

	filedriver "github.com/goftp/file-driver"
	"github.com/goftp/server"
)

var (
	flagRoot = flag.String("root", "", "Directory to serve files")
	flagUser = flag.String("user", "admin", "Username for login")
	flagPass = flag.String("pass", "123456", "Password for login")
	flagPort = flag.Int("port", 2121, "TCP port to listen on")
	flagHost = flag.String("host", "localhost", "TCP address to listen on")

	flagPassivePorts = flag.String("passive-ports", "", "Passive TCP port range to listen on (example: 30000-30009)")
)

func main() {
	flag.Parse()

	if *flagRoot == "" {
		log.Fatalf("Please set a directory to serve with -root")
	}

	factory := &filedriver.FileDriverFactory{
		RootPath: *flagRoot,
		Perm:     server.NewSimplePerm("user", "group"),
	}

	opts := &server.ServerOpts{
		Factory:      factory,
		Port:         *flagPort,
		Hostname:     *flagHost,
		Auth:         &server.SimpleAuth{Name: *flagUser, Password: *flagPass},
		PassivePorts: *flagPassivePorts,
	}

	log.Printf("Starting FTP server on %v:%v", opts.Hostname, opts.Port)
	log.Printf("Username %v, Password %v", *flagUser, *flagPass)
	server := server.NewServer(opts)
	err := server.ListenAndServe()
	if err != nil {
		log.Fatal("Error starting server:", err)
	}
}
