package main

import "core:log"
import "core:math"
import "vendor:sdl3"

GameScene :: proc() -> Scene(State) {
	return Scene(State){init = Init, tick = Tick, fixed_tick = FixedTick, deinit = Deinit}
}

@(private)
State :: struct {
	color: struct {
		r: f32,
		g: f32,
		b: f32,
	},
}

@(private)
Tick :: proc(this: ^State, engine: ^Engine, t: f32, dt: f32) {
	this.color.r = math.sin_f32(t * 2.0);

	cmd_buf := sdl3.AcquireGPUCommandBuffer(engine.gpu)
	if cmd_buf == nil {
		log.errorf("AcquireGPUCommandBuffer failed: %s", sdl3.GetError())
		return
	}

	swapchain_tex: ^sdl3.GPUTexture
	if !sdl3.WaitAndAcquireGPUSwapchainTexture(cmd_buf, engine.window, &swapchain_tex, nil, nil) {
		log.errorf("WaitAndAcquireGPUSwapchainTexture failed: %s", sdl3.GetError())
		_ = sdl3.CancelGPUCommandBuffer(cmd_buf)
		return
	}

	if swapchain_tex != nil {
		color_target := sdl3.GPUColorTargetInfo {
			texture     = swapchain_tex,
			clear_color = {this.color.r, this.color.g, this.color.b, 1.0},
			load_op     = .CLEAR,
			store_op    = .STORE,
		}

		render_pass := sdl3.BeginGPURenderPass(cmd_buf, &color_target, 1, nil)
		sdl3.EndGPURenderPass(render_pass)
	}

	if !sdl3.SubmitGPUCommandBuffer(cmd_buf) {
		log.errorf("SubmitGPUCommandBuffer failed: %s", sdl3.GetError())
	}
}

@(private)
FixedTick :: proc(this: ^State, engine: ^Engine, t: f32, dt: f32) {
	this.color.b = math.sin_f32(t * 2.0 + math.PI);
}

@(private)
Init :: proc(engine: ^Engine) -> ^State {
	this := new(State)
	this.color = {0, 0, 0}

	return this
}

@(private)
Deinit :: proc(this: ^State, engine: ^Engine) {
	free(this)
}
