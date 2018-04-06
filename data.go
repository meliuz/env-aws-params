package main

import (
	"fmt"
	"path"
	"regexp"
	"strings"
)

var InvalidPattern = regexp.MustCompile(`[^a-zA-Z0-9_]`)

func BuildEnvVars(parameters map[string]string, basename bool, sanitize bool, strip bool, upcase bool) []string {
	var vars []string

	for k, v := range parameters {
		if basename == true {
			k = path.Base(k)
		}
		if sanitize == true {
			k = InvalidPattern.ReplaceAllString(k, "_")
		}
		if strip == true {
			k = InvalidPattern.ReplaceAllString(k, "")
		}
		if upcase == true {
			k = strings.ToUpper(k)
		}
		vars = append(vars, fmt.Sprintf("%s=%s", k, v))
	}
	return vars
}
