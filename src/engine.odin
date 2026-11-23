package main

import "vendor:sdl3"

Engine :: struct {
	window: ^sdl3.Window,
	gpu:    ^sdl3.GPUDevice,
}
