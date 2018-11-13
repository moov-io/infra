// Copyright 2018 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

package gofuzz

import (
	"testing"
)

func TestParse(t *testing.T) {
	cases := []string{
		`2018/10/17 21:19:15 workers: 2, corpus: 26 (3s ago), crashers: 1, restarts: 1/0, execs: 1 (0/sec), cover: 0, uptime: 3s`,
		`2018/10/17 21:19:24 workers: 2, corpus: 26 (12s ago), crashers: 1, restarts: 1/7306, execs: 29224 (2401/sec), cover: 0, uptime: 12s`,
		`2018/10/17 23:55:15 workers: 2, corpus: 112 (13m28s ago), crashers: 1, restarts: 1/9985, execs: 22688133 (2423/sec), cover: 1835, uptime: 2h36m`,
	}
	for i := range cases {
		line, err := ParseLine(cases[i])
		if err != nil {
			t.Errorf("%q - %v", cases[i], err)
		}

		if line.Timestamp.IsZero() {
			t.Errorf("%q line.Timestamp=%v", cases[i], line.Timestamp)
		}
		if line.WorkerCount == 0 {
			t.Errorf("%q line.WorkerCount=%d", cases[i], line.WorkerCount)
		}
		if line.CorpusCount == 0 {
			t.Errorf("%q line.CorpusCount=%d", cases[i], line.CorpusCount)
		}
		if line.CrashersCount == 0 {
			t.Errorf("%q line.CrashersCount=%d", cases[i], line.CrashersCount)
		}
		if line.Executions == 0 {
			t.Errorf("%q line.Executions=%d", cases[i], line.Executions)
		}
		if line.Uptime == 0 {
			t.Errorf("%q line.Uptime=%d", cases[i], line.Uptime)
		}
	}
}
