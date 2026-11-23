package main

import "core:log"
import "core:os"

import "vendor:sdl3"


run :: proc() -> int {
	// Logger init
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	// SDL init
	meta_ok := sdl3.SetAppMetadata("Vroom", "0.1.0", "com.amirreiter.vroom")
	sdl_ok := sdl3.Init({.VIDEO, .AUDIO})
	defer sdl3.Quit()

	if !meta_ok | !sdl_ok {
		log.errorf("Failed to init SDL3: %s", sdl3.GetError())
		return 1
	}

	// GPU init
	gpu := sdl3.CreateGPUDevice({.SPIRV, .DXIL, .MSL}, ODIN_DEBUG, nil)
	defer sdl3.DestroyGPUDevice(gpu)

	if gpu == nil {
		log.errorf("Failed to create GPU device: %s", sdl3.GetError())
		return 1
	}

	// Window init
	window := sdl3.CreateWindow("Vroom", 1280, 720, {.RESIZABLE, .HIGH_PIXEL_DENSITY})
	defer sdl3.DestroyWindow(window)

	if window == nil {
		log.errorf("Failed to create window: %s", sdl3.GetError())
		return 1
	}

	if !sdl3.ClaimWindowForGPUDevice(gpu, window) {
		log.errorf("Failed to bind gpu device to window: %s", sdl3.GetError())
		return 1
	}

	engine := Engine {
		gpu = gpu,
		window = window,
	};

	initial_scene := GameScene();

	run_event_loop(&engine, &initial_scene);

	return 0
}

main :: proc() {
	os.exit(run());
}
