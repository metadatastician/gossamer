// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android component host test aggregator
//
// The Android JNI binding (jni.zig) and the non-UI component hosts
// (android_components / android_service / android_receiver / android_widget)
// are written in pure Zig with no Android headers, so their dispatch,
// registry, JSON-event and directive logic is HOST-RUNNABLE. This aggregator
// pulls those files' `test` blocks into `zig build test` / `zig build
// test-android`, so the component contract is exercised on the Linux CI runner
// even though a phone (and the NDK) are nowhere in sight.
//
// What is NOT covered here: the actual JNI calls through a live JNIEnv (those
// require a device/emulator). The `export fn Java_io_gossamer_*` entry points
// compile in this binary but are never invoked — they are validated on-device.

test {
    _ = @import("../src/jni.zig");
    _ = @import("../src/android_components.zig");
    _ = @import("../src/android_service.zig");
    _ = @import("../src/android_receiver.zig");
    _ = @import("../src/android_widget.zig");
}
