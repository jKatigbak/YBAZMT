package main

// could probably use something like gomplate + config file to make this more generic
// https://github.com/hairyhenderson/gomplate
import (
	caddycmd "github.com/caddyserver/caddy/v2/cmd"

	// plug in Caddy modules here
	_ "github.com/caddyserver/caddy/v2/modules/standard"
)

func main() {
	caddycmd.Main()
}