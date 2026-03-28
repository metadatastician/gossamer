// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer V-lang API — Webview shell and panel workspace client.
module gossamer

pub enum GossamerResult {
	ok
	@error
	invalid_param
	webview_unavailable
	capability_denied
	not_found
}

pub struct WindowConfig {
pub:
	title       string
	width       int
	height      int
	resizable   bool
	decorations bool
	fullscreen  bool
}

pub struct PanelManifest {
pub:
	id           string
	name         string
	version      string
	entry_point  string
	capabilities []string
}

fn C.gossamer_create(title_ptr &u8, w u32, h u32, resizable u32, decorations u32, fullscreen u32) u64
fn C.gossamer_load_html(handle u64, html_ptr &u8) u32
fn C.gossamer_navigate(handle u64, url_ptr &u8) u32
fn C.gossamer_eval(handle u64, js_ptr &u8) u32
fn C.gossamer_run(handle u64)
fn C.gossamer_destroy(handle u64)
fn C.gossamer_version() u64

// create creates a new webview window. Returns handle or 0 on failure.
pub fn create(config WindowConfig) !u64 {
	handle := C.gossamer_create(config.title.str,
		u32(config.width), u32(config.height),
		if config.resizable { u32(1) } else { u32(0) },
		if config.decorations { u32(1) } else { u32(0) },
		if config.fullscreen { u32(1) } else { u32(0) })
	if handle == 0 {
		return error('webview creation failed')
	}
	return handle
}

// load_html loads HTML content into the webview.
pub fn load_html(handle u64, html string) !bool {
	result := C.gossamer_load_html(handle, html.str)
	if result != 0 {
		return error('load_html failed: ${result}')
	}
	return true
}

// navigate navigates the webview to a URL.
pub fn navigate(handle u64, url string) !bool {
	result := C.gossamer_navigate(handle, url.str)
	if result != 0 {
		return error('navigate failed: ${result}')
	}
	return true
}

// eval evaluates JavaScript in the webview context.
pub fn eval_js(handle u64, js string) !bool {
	result := C.gossamer_eval(handle, js.str)
	if result != 0 {
		return error('eval failed: ${result}')
	}
	return true
}

// run runs the webview event loop (blocks until closed, consumes handle).
pub fn run(handle u64) {
	C.gossamer_run(handle)
}

// destroy destroys the webview without running the event loop.
pub fn destroy(handle u64) {
	C.gossamer_destroy(handle)
}
