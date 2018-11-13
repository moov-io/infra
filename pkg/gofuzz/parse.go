// Copyright 2018 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

// gofuzz is a package to parse go-fuzz log lines. This can be used to
// monitor fuzz progress.
//
// See: https://github.com/dvyukov/go-fuzz
package gofuzz

import (
	"fmt"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

type Line struct {
	// Time of when this line was emitted. Local to where go-fuzz runs from
	Timestamp time.Time

	// Count of active workers
	WorkerCount int64

	// Count of example inputs in corput
	// go-fuzz will add more during execution
	CorpusCount int64

	// Count of inputs have caused a panic
	CrashersCount int64

	// Total count of calls to Fuzz method
	Executions int64

	// Total execution time across workers
	Uptime time.Duration
}

var (
	// Example: 2018/10/17 21:19:15
	timestampFormat       = "2006/01/02 15:04:05"
	timestampFormatLength = utf8.RuneCountInString(timestampFormat)
)

func ParseLine(raw string) (*Line, error) {
	raw = strings.TrimSpace(raw)

	// Sanity length check
	if utf8.RuneCountInString(raw) < timestampFormatLength {
		return nil, fmt.Errorf("line is too short: %q", raw)
	}

	line := &Line{}

	// Grab timestamp
	t, err := parseTimestamp(raw[:timestampFormatLength])
	if err != nil {
		return nil, err
	}
	line.Timestamp = t

	raw = strings.TrimSpace(raw[timestampFormatLength:])
	chunks := strings.Split(raw, ", ")
	for i := range chunks {
		parts := strings.Split(chunks[i], " ")
		if len(parts) < 2 {
			continue
		}

		switch parts[0] {
		case "workers:":
			line.WorkerCount = convert(parts[1])
		case "corpus:":
			line.CorpusCount = convert(parts[1])
		case "crashers:":
			line.CrashersCount = convert(parts[1])
		case "execs:":
			line.Executions = convert(parts[1])
		case "uptime:":
			d, err := time.ParseDuration(parts[1])
			if err == nil {
				line.Uptime = d
			}
		}
	}
	return line, nil
}

func convert(raw string) int64 {
	parts := strings.Split(raw, " ")
	if len(parts) < 1 {
		return -1
	}
	n, _ := strconv.Atoi(parts[0])
	return int64(n)
}

func parseTimestamp(raw string) (time.Time, error) {
	return time.Parse(timestampFormat, raw)
}
