package code

import (
	"bytes"
	"fmt"
	"reflect"
)

func add(a, b int) int {
	return a + b
}

func reflectCall(buf *bytes.Buffer) {
	fn := reflect.ValueOf(add)

	args := []reflect.Value{
		reflect.ValueOf(5),
		reflect.ValueOf(3),
	}

	results := fn.Call(args) //nolint:forbidigo
	if len(results) > 0 {
		buf.WriteString(fmt.Sprintf("add(5, 3) = %v", results[0].Interface()))
	}
}
