// Copyright 2019 The Moov Authors
// Use of this source code is governed by an Apache License
// license that can be found in the LICENSE file.

package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"runtime"
)

var (
	flagVerbose = flag.Bool("verbose", false, "Verbose: show all log output")

	mixinConfigMap = []byte(`apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-kubernets-monitoring
  namespace: infra
data:
  # THIS FILE WAS GENERATED FROM https://github.com/kubernetes-monitoring/kubernetes-mixin
  prometheus_alerts.yml: |
`)
)

func main() {
	flag.Parse()

	// Verify we are in the root of infra/
	wd, err := os.Getwd()
	if dir := filepath.Base(wd); dir != "infra" || wd == "" {
		log.Fatalf("ERROR: unknown directory 'kubernetes-mixins' is ran from: %s", dir)
	}

	switch runtime.GOOS {
	case "darwin", "linux": // allowed platforms
	default:
		fmt.Printf("infra/kubernetes-mixins is not supported on %s yet", runtime.GOOS)
		os.Exit(1)
	}

	// Install jsonnet and jsonnet-bundler
	if err := installJsonnet(); err != nil {
		log.Fatal(err)
	}
	// Download kubernetes-mixin code
	dir, err := buildMixins()
	if err != nil {
		log.Printf("Temp directory %s created", dir)
		log.Fatal(err)
	}
	defer os.RemoveAll(dir)

	// Copy over generated files to infra/ repository
	// We only care about 'prometheus_alerts.yaml' right now.
	bs, err := ioutil.ReadFile(filepath.Join(dir, "kubernetes-mixin", "prometheus_alerts.yaml"))
	if os.IsNotExist(err) {
		log.Fatal(err)
	}

	// Rigth now we only render envs/prod and the rendered prometheus_alerts.yaml file
	path := filepath.Join(wd, "envs", "prod", "infra", "14-prometheus-kubernetes-mixin.yml")

	indent := []byte("\n      ")
	content := append(append(mixinConfigMap, []byte("    ")...), bytes.Replace(bs, []byte("\n"), indent, -1)...)

	// Write YAML files into repo
	if err := ioutil.WriteFile(path, content, 0644); err != nil {
		log.Fatalf("ERROR writing prometheus alerts/rules: %v", err)
	}

	// TODO(adam): copy over dashboards
	// $ make dashboards_out
	// jsonnet -J vendor -m dashboards_out lib/dashboards.jsonnet
	// dashboards_out/k8s-cluster-rsrc-use.json
	// dashboards_out/k8s-node-rsrc-use.json
	// dashboards_out/k8s-resources-cluster.json
	// dashboards_out/k8s-resources-namespace.json
	// dashboards_out/k8s-resources-pod.json
	// dashboards_out/nodes.json
	// dashboards_out/persistentvolumesusage.json
	// dashboards_out/pods.json
	// dashboards_out/statefulset.json
}
