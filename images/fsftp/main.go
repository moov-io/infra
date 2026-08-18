// Copyright 2020 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

package main

import (
	"flag"
	"log"

	"goftp.io/server/v2"
	"goftp.io/server/v2/driver/file"
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
		log.Fatal("Please set a directory to serve with -root")
	}

	driver, err := file.NewDriver(*flagRoot)
	if err != nil {
		log.Fatal("Error creating file driver:", err)
	}

	opts := &server.Options{
		Driver:       driver,
		Port:         *flagPort,
		Hostname:     *flagHost,
		Auth:         &server.SimpleAuth{Name: *flagUser, Password: *flagPass},
		Perm:         server.NewSimplePerm("user", "group"),
		PassivePorts: *flagPassivePorts,
	}

	log.Printf("Starting FTP server on %v:%v", opts.Hostname, opts.Port)
	if *flagPass != "" {
		log.Printf("Username %v, password is set", *flagUser)
	} else {
		log.Printf("Username %v, password is empty", *flagUser)
	}
	s, err := server.NewServer(opts)
	if err != nil {
		log.Fatal("Error creating server:", err)
	}
	err = s.ListenAndServe()
	if err != nil {
		log.Fatal("Error starting server:", err)
	}
}
