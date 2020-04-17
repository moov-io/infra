// Copyright 2020 The Moov Authors
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

	// baseConfigMap is a Kubernetes object template for the ConfigMap's that
	// hold the Prometheus configuration.
	baseConfigMap = []byte(`apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-kubernets-monitoring-%s
  namespace: infra
data:
  # THIS FILE WAS GENERATED FROM https://github.com/kubernetes-monitoring/kubernetes-mixin
  prometheus_%s.yml: |
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
	if err := copyFile(dir, wd, "alerts"); err != nil {
		log.Fatal(err)
	}
	if err := copyFile(dir, wd, "rules"); err != nil {
		log.Fatal(err)
	}

	// TODO(adam): Since we run on GKE we should be ignoring the scrape jobs for
	// kube-controller-manager and kube-scheduler because they're managed for us outside of our view.
	//
	// See: https://github.com/camilb/prometheus-kubernetes/issues/48

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

func copyFile(dir, wd, stub string) error {
	filename := fmt.Sprintf("prometheus_%s.yaml", stub)
	bs, err := ioutil.ReadFile(filepath.Join(dir, "kubernetes-mixin", filename))
	if os.IsNotExist(err) {
		return fmt.Errorf("file %s didn't exist: %v", filename, err)
	}

	// Right now we only render envs/oss and the rendered prometheus_alerts.yaml file
	path := filepath.Join(wd, "envs", "oss", "infra", fmt.Sprintf("14-prometheus-kubernetes-mixin-%s.yml", stub))

	indent := []byte("\n      ")

	base := bytes.Replace(baseConfigMap, []byte("%s"), []byte(stub), -1)
	content := append(append(base, []byte("    ")...), bytes.Replace(bs, []byte("\n"), indent, -1)...)

	// Write YAML files into repo
	if err := ioutil.WriteFile(path, content, 0644); err != nil {
		return fmt.Errorf("ERROR writing prometheus %s: %v", stub, err)
	}
	return nil

}
