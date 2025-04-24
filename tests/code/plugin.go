package code

import (
	"log"
	"plugin"
)

func openPlugin() {
	_, err := plugin.Open("does/not/exist.so") //nolint:forbidigo
	if err == nil {
		log.Fatal("expected error")
	}
}
