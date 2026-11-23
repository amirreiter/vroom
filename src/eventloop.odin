package main

import sdl3 "vendor:sdl3"

TICKRATE :: f64(1.0 / 5.0)
MAX_FRAME_TIME :: f64(1.0 / 60.0)

Scene :: struct($T: typeid) {
	state:      ^T,
	init:       proc(engine: ^Engine) -> ^T,
	tick:       proc(this: ^T, engine: ^Engine, t: f32, dt: f32),
	fixed_tick: proc(this: ^T, engine: ^Engine, t: f32, fixed_dt: f32),
	deinit:     proc(this: ^T, engine: ^Engine),
}

run_event_loop :: proc(engine: ^Engine, initial_scene: ^Scene($T)) -> int {
	scene := initial_scene
	if scene.init != nil {
		state := scene.init(engine)
		if state == nil {
			return 1
		}
		scene.state = state
	}
	defer if scene.deinit != nil {
		scene.deinit(scene.state, engine)
	}

	perf_freq := f64(sdl3.GetPerformanceFrequency())
	prev_ticks := sdl3.GetPerformanceCounter()
	accumulator := f64(0.0)
	sim_time := f64(0.0)
	total_time := f64(0.0)

	running := true
	for running {
		now := sdl3.GetPerformanceCounter()
		frame_time := f64(now - prev_ticks) / perf_freq
		prev_ticks = now

		if frame_time > MAX_FRAME_TIME {
			frame_time = MAX_FRAME_TIME
		}

		accumulator += frame_time
		total_time += frame_time

		event: sdl3.Event
		for sdl3.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				running = false
			case .KEY_DOWN:
				if event.key.key == sdl3.K_ESCAPE {
					running = false
				}
			}
		}

		if scene.fixed_tick != nil {
			for accumulator >= TICKRATE {
				scene.fixed_tick(scene.state, engine, f32(sim_time), f32(TICKRATE))
				sim_time += TICKRATE
				accumulator -= TICKRATE
			}
		}

		if scene.tick != nil {
			scene.tick(scene.state, engine, f32(total_time), f32(frame_time))
		}
	}

	return 0
}
