// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android component host test aggregator
//
// The Android JNI binding (jni.zig) and the non-UI component hosts
// (android_components / android_service / android_receiver / android_widget)
// are written in pure Zig with no Android headers, so their dispatch,
// registry, JSON-event and directive logic is HOST-RUNNABLE. This aggregator
// pulls those files' `test` blocks into `zig build test-android`, so the
// component contract is exercised on a normal CI runner — no phone, no NDK.
//
// It lives in src/ (not test/) on purpose: Zig 0.15 forbids a module from
// importing files outside its own root directory, so a test/ aggregator cannot
// `@import("../src/jni.zig")`. Rooting here keeps every import same-directory.
// Nothing in the library build graph reaches this file (main.zig never imports
// it), so it is compiled only by the `test-android` step.
//
// What is NOT covered: the actual JNI calls through a live JNIEnv (those need a
// device/emulator). The `export fn Java_io_gossamer_*` entry points compile in
// this binary but are never invoked — they are validated on-device.

test {
    _ = @import("jni.zig");
    _ = @import("android_components.zig");
    _ = @import("android_service.zig");
    _ = @import("android_receiver.zig");
    _ = @import("android_widget.zig");
}
