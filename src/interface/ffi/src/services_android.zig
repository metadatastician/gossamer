// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android subclass-base "services" host (issue #71, native half)
//
// Native side of the hand-authored `io.gossamer.services.*` base classes
// (GossamerForegroundService / GossamerBootReceiver / GossamerAppWidgetProvider)
// plus the services-variant GossamerActivity.onNewIntent hook. Where the
// earlier directive component layer (now removed) routed every lifecycle event
// through a STRING directive registry, this surface is the lower-level,
// per-instance boundary an app's native core (e.g. neurophone's Rust) drives
// directly:
//
//   * A foreground Service is a LINEAR, per-instance resource (created once at
//     onCreate, destroyed once at onDestroy — the exact SvcCreated -> SvcStarted*
//     -> SvcDestroyed machine modelled in Gossamer.ABI.AndroidComponents). It
//     therefore gets its OWN opaque `ServiceHandle`, deliberately INDEPENDENT of
//     the webview `GossamerHandle`: a Service can outlive (or exist without) any
//     Activity, so coupling the two would be a lifetime bug. The handle is a
//     heap pointer the JVM round-trips as a `long`.
//
//   * Sensor samples are hot and primitive, so they cross as a raw
//     `float[]` + `Sensor.TYPE_*` int (NOT JSON). gossamer reads the array
//     through JNI and hands the app a `[*]const f32` + length — zero parsing.
//
//   * Config and widget state cross as JSON strings (cold path, human-shaped).
//
// The app plugs in WITHOUT touching JNI: it registers a small set of pure C-ABI
// callbacks (see the `gossamer_android_register_*` exports), and gossamer owns
// every JNIEnv call, every global ref, and every array borrow/release. This is
// the same "app stays pure, gossamer owns the FFI" contract the webview IPC
// uses, specialised to the subclass-base shapes #71 introduces.
//
// Pure Zig, no Android headers: the registry, the ServiceHandle alloc/lookup/
// free, and the JSON helper are HOST-RUNNABLE (see the `test` blocks). The
// `export fn Java_io_gossamer_*` entry points compile on the host as ordinary
// Zig but are never invoked there — there is no live JNIEnv off-device.

const std = @import("std");
const jni = @import("jni.zig");

/// Every `ServiceHandle` and the JSON it owns is allocated here so the JVM can
/// round-trip the pointer as a `long` across an arbitrary number of calls.
const c_alloc = std.heap.c_allocator;

//==============================================================================
// Process-global app-callback registry
//
// The app registers PURE function pointers once (typically from its native
// `init` / `JNI_OnLoad`); gossamer stores them in these globals and invokes
// them from the JNI entry points below. None of these signatures mention a
// JNIEnv — that is the whole point. All are optional: a null slot means "no app
// handler", and gossamer applies a safe default (START_STICKY, "{}", do not
// restart, …).
//==============================================================================

/// Service lifecycle callbacks (one set, process-wide — there is normally a
/// single foreground Service class per app).
///   create(handle, config_json)                         — service constructed
///   start(handle, action, flags, start_id) -> sticky    — onStartCommand; the
///        return value is the Android START_* code (START_STICKY = 1 default)
///   destroy(handle)                                      — service torn down
///   sensor(handle, type, values, len, ts_ns, accuracy)  — one sensor sample;
///        `values` is borrowed for the call only (do not retain past return)
const ServiceCreateFn = *const fn (handle: u64, config_json: [*:0]const u8) callconv(.c) void;
const ServiceStartFn = *const fn (handle: u64, action: [*:0]const u8, flags: i32, start_id: i32) callconv(.c) i32;
const ServiceDestroyFn = *const fn (handle: u64) callconv(.c) void;
const ServiceSensorFn = *const fn (handle: u64, sensor_type: i32, values: [*]const f32, len: u32, timestamp_ns: i64, accuracy: i32) callconv(.c) void;

/// Widget callbacks.
///   fetch_state(out_json_cap) -> json   — return CURRENT widget state as a
///        handler-owned NUL-terminated JSON string. `out_json_cap` is an
///        advisory capacity hint (the RemoteViews text budget); the handler may
///        ignore it. The returned pointer is borrowed by gossamer for the
///        NewStringUTF copy only.
///   handle_action(action, widget_id)    — a custom widget tap fired.
const WidgetFetchStateFn = *const fn (out_json_cap: usize) callconv(.c) [*:0]const u8;
const WidgetHandleActionFn = *const fn (action: [*:0]const u8, widget_id: i32) callconv(.c) void;

/// Boot callback: should the named service class be restarted now? Return 1 to
/// restart, 0 to skip. Keyed by class name so one app can host several services.
const BootShouldRestartFn = *const fn (service_class: [*:0]const u8) callconv(.c) u8;

/// Intent callback: the (services-variant) Activity was re-delivered an Intent.
/// Receives a small JSON envelope; gossamer extracts what it cheaply can.
const IntentOnIntentFn = *const fn (intent_json: [*:0]const u8) callconv(.c) void;

var cb_service_create: ?ServiceCreateFn = null;
var cb_service_start: ?ServiceStartFn = null;
var cb_service_destroy: ?ServiceDestroyFn = null;
var cb_service_sensor: ?ServiceSensorFn = null;

var cb_widget_fetch_state: ?WidgetFetchStateFn = null;
var cb_widget_handle_action: ?WidgetHandleActionFn = null;

var cb_boot_should_restart: ?BootShouldRestartFn = null;

var cb_intent_on_intent: ?IntentOnIntentFn = null;

/// Advisory capacity hint passed to the widget `fetch_state` callback. The
/// RemoteViews text budget is small; 4 KiB is comfortably above any single
/// widget's JSON. Exposed as a constant so the value lives in exactly one place.
const WIDGET_STATE_CAP: usize = 4096;

/// Register the foreground-Service lifecycle callbacks. Pass null for any the
/// app does not need; gossamer applies its default for the missing ones. Safe
/// to call again to re-point (idempotent, last writer wins).
export fn gossamer_android_register_service_callbacks(
    create: ?ServiceCreateFn,
    start: ?ServiceStartFn,
    destroy: ?ServiceDestroyFn,
    sensor: ?ServiceSensorFn,
) void {
    cb_service_create = create;
    cb_service_start = start;
    cb_service_destroy = destroy;
    cb_service_sensor = sensor;
}

/// Register the widget callbacks. `fetch_state` returns a handler-owned
/// NUL-terminated JSON string (gossamer only reads it); `handle_action` reacts
/// to a custom widget tap.
export fn gossamer_android_register_widget_callbacks(
    fetch_state: ?WidgetFetchStateFn,
    handle_action: ?WidgetHandleActionFn,
) void {
    cb_widget_fetch_state = fetch_state;
    cb_widget_handle_action = handle_action;
}

/// Register the boot callback deciding whether a service restarts on boot.
export fn gossamer_android_register_boot_callback(
    should_restart: ?BootShouldRestartFn,
) void {
    cb_boot_should_restart = should_restart;
}

/// Register the Activity new-intent callback.
export fn gossamer_android_register_intent_callback(
    on_intent: ?IntentOnIntentFn,
) void {
    cb_intent_on_intent = on_intent;
}

//==============================================================================
// ServiceHandle — per-service opaque native state (INDEPENDENT of GossamerHandle)
//==============================================================================

/// Per-service native state. Allocated once at `nativeServiceCreate`, freed once
/// at `nativeServiceDestroy`; the JVM holds the only reference between the two as
/// a `long`. Deliberately NOT shared with the webview `GossamerHandle`: a Service
/// has its own lifetime and may run with no Activity in scope.
pub const ServiceHandle = struct {
    /// Process JavaVM, cached so off-thread native workers (a sensor-processing
    /// thread the app spins up) can attach and obtain their own env. JNIEnv is
    /// strictly thread-local, so the env from `nativeServiceCreate` must never be
    /// reused off the thread that created it — attach via this VM instead.
    vm: ?jni.JavaVM = null,
    /// Global ref to the Java `Service` object. Promoted from the local ref Java
    /// passes at create (that local is invalid the instant the call returns), and
    /// deleted at destroy. May be null if promotion failed.
    service: jni.jobject = null,
    /// The config JSON bytes handed in at create, owned (heap, NUL-terminated)
    /// for the life of the handle so the app may read it after create returns.
    config: [:0]u8,
    /// Opaque app pointer, threaded through if the app wants to associate its own
    /// per-service state. gossamer never dereferences it.
    user_data: ?*anyopaque = null,
};

/// Recover a `*ServiceHandle` from the `long` the JVM round-trips. Returns null
/// for a 0 / negative handle (defensive: the Java side initialises the field to
/// 0 and only overwrites it on a successful create).
fn handleFromLong(handle: i64) ?*ServiceHandle {
    if (handle <= 0) return null;
    return @ptrFromInt(@as(usize, @intCast(handle)));
}

/// Encode a `*ServiceHandle` as the `long` returned to the JVM. Mirrors the
/// `@intCast(@intFromPtr(...))` form `main.zig` uses for its channel handles.
fn handleToLong(h: *ServiceHandle) i64 {
    return @intCast(@intFromPtr(h));
}

/// Allocate a `ServiceHandle` owning a copy of `config_json`. Host-testable: it
/// takes no JNIEnv and performs no JNI. Returns null on OOM.
fn allocServiceHandle(config_json: []const u8, user_data: ?*anyopaque) ?*ServiceHandle {
    const h = c_alloc.create(ServiceHandle) catch return null;
    const cfg = c_alloc.dupeZ(u8, config_json) catch {
        c_alloc.destroy(h);
        return null;
    };
    h.* = .{
        .vm = null,
        .service = null,
        .config = cfg,
        .user_data = user_data,
    };
    return h;
}

/// Free a `ServiceHandle` and the config it owns. Does NOT touch JNI (the global
/// ref is deleted by the caller while a valid env is in hand). Host-testable.
fn freeServiceHandle(h: *ServiceHandle) void {
    c_alloc.free(h.config);
    c_alloc.destroy(h);
}

//==============================================================================
// Small JNI helpers (services-local)
//==============================================================================

/// Read `android.content.Intent.getAction()` as an owned, NUL-terminated copy,
/// or null if `intent` is null / has no action / JNI fails. The caller owns the
/// returned slice and must free it with `c_alloc`. Kept self-contained so the
/// Service start path and the Activity intent path share one implementation.
fn intentActionOwned(env: jni.JNIEnv, intent: jni.jobject) ?[:0]u8 {
    const obj = intent orelse return null;
    const cls = jni.findClass(env, "android/content/Intent");
    if (cls == null) {
        _ = jni.clearPendingException(env);
        return null;
    }
    const mid = jni.getMethodID(env, cls, "getAction", "()Ljava/lang/String;");
    if (mid == null) {
        _ = jni.clearPendingException(env);
        return null;
    }
    const action_str = jni.callObjectMethod(env, obj, mid, &.{});
    _ = jni.clearPendingException(env);
    const s = action_str orelse return null;
    const chars = jni.getStringUTFChars(env, s) orelse return null;
    defer jni.releaseStringUTFChars(env, s, chars);
    return c_alloc.dupeZ(u8, std.mem.span(chars)) catch null;
}

//==============================================================================
// JNI exports — GossamerForegroundService
//
// Names MUST match the Java declarations in
// io/gossamer/services/GossamerForegroundService.java exactly. These are STATIC
// native methods, so the second JNI argument is the defining `jclass`.
//==============================================================================

/// `private static native long nativeServiceCreate(Service self, String configJson)`
///
/// Promote `service` to a GLOBAL ref, copy the config bytes, allocate the
/// independent ServiceHandle, cache the JavaVM, invoke the app `create` callback,
/// and return the handle as a `long`. Returns 0 on allocation failure (the Java
/// side treats 0 as "no native handle" and simply never calls back in).
export fn Java_io_gossamer_services_GossamerForegroundService_nativeServiceCreate(
    env: jni.JNIEnv,
    _: jni.jclass,
    service: jni.jobject,
    config_json: jni.jstring,
) i64 {
    // Read config (UTF chars) into an owned slice via the handle allocator.
    var config_slice: []const u8 = "{}";
    var config_chars: ?[*:0]const u8 = null;
    if (config_json != null) {
        config_chars = jni.getStringUTFChars(env, config_json);
        if (config_chars) |ch| config_slice = std.mem.span(ch);
    }
    defer if (config_chars) |ch| jni.releaseStringUTFChars(env, config_json, ch);

    const h = allocServiceHandle(config_slice, null) orelse return 0;

    // Cache the VM (for off-thread attach) and promote the Service to a global
    // ref so it stays valid across the whole service lifetime.
    h.vm = jni.getJavaVM(env);
    h.service = jni.newGlobalRef(env, service);

    const handle_id: u64 = @intCast(@intFromPtr(h));
    if (cb_service_create) |cb| cb(handle_id, h.config.ptr);
    _ = jni.clearPendingException(env);
    return handleToLong(h);
}

/// `private static native int nativeServiceStartCommand(long handle, Intent intent, int flags, int startId)`
///
/// Recover the handle, extract the Intent action if present (else ""), dispatch
/// to the app `start` callback, and return its Android START_* code. Defaults to
/// START_STICKY (1) when there is no handle or no callback.
export fn Java_io_gossamer_services_GossamerForegroundService_nativeServiceStartCommand(
    env: jni.JNIEnv,
    _: jni.jclass,
    handle: i64,
    intent: jni.jobject,
    flags: jni.jint,
    start_id: jni.jint,
) i32 {
    const START_STICKY: i32 = 1;
    const h = handleFromLong(handle) orelse return START_STICKY;
    const cb = cb_service_start orelse return START_STICKY;

    const action_owned = intentActionOwned(env, intent);
    defer if (action_owned) |a| c_alloc.free(a);
    const action_ptr: [*:0]const u8 = if (action_owned) |a| a.ptr else "";

    const rc = cb(@intCast(@intFromPtr(h)), action_ptr, @intCast(flags), @intCast(start_id));
    _ = jni.clearPendingException(env);
    return rc;
}

/// `private static native void nativeServiceDestroy(long handle)`
///
/// Dispatch the app `destroy` callback, delete the Service global ref (while a
/// valid env is in hand), then free the handle. Terminal: nothing may dispatch
/// against this handle afterwards (the JVM drops its `long`).
export fn Java_io_gossamer_services_GossamerForegroundService_nativeServiceDestroy(
    env: jni.JNIEnv,
    _: jni.jclass,
    handle: i64,
) void {
    const h = handleFromLong(handle) orelse return;
    if (cb_service_destroy) |cb| cb(@intCast(@intFromPtr(h)));
    if (h.service) |svc| jni.deleteGlobalRef(env, svc);
    h.service = null;
    _ = jni.clearPendingException(env);
    freeServiceHandle(h);
}

/// `private static native void nativeSensorEvent(long handle, int sensorType, float[] values, long timestampNs, int accuracy)`
///
/// Borrow the `float[]` backing store, hand the app `sensor` callback a
/// `[*]const f32` + element count, then release the borrow with JNI_ABORT (the
/// native side only reads, so no copy-back). No allocation on this hot path.
export fn Java_io_gossamer_services_GossamerForegroundService_nativeSensorEvent(
    env: jni.JNIEnv,
    _: jni.jclass,
    handle: i64,
    sensor_type: jni.jint,
    values: jni.jfloatArray,
    timestamp_ns: i64,
    accuracy: jni.jint,
) void {
    const h = handleFromLong(handle) orelse return;
    const cb = cb_service_sensor orelse return;
    const arr = values orelse return;

    const len_signed = jni.getArrayLength(env, arr);
    if (len_signed <= 0) return;
    const elems = jni.getFloatArrayElements(env, arr) orelse return;
    defer jni.releaseFloatArrayElements(env, arr, elems, jni.JNI_ABORT);

    const len: u32 = @intCast(len_signed);
    cb(@intCast(@intFromPtr(h)), @intCast(sensor_type), elems, len, timestamp_ns, @intCast(accuracy));
    _ = jni.clearPendingException(env);
}

//==============================================================================
// JNI exports — GossamerBootReceiver
//==============================================================================

/// `private static native boolean nativeShouldRestart(Context context, String serviceClassName)`
///
/// Read the service class name, ask the app `should_restart` callback, and
/// return its boolean. Defaults to false (0 / do not restart) when there is no
/// callback or the class name is unreadable — the conservative choice.
export fn Java_io_gossamer_services_GossamerBootReceiver_nativeShouldRestart(
    env: jni.JNIEnv,
    _: jni.jclass,
    context: jni.jobject,
    service_class_name: jni.jstring,
) jni.jboolean {
    _ = context;
    const cb = cb_boot_should_restart orelse return jni.JNI_FALSE;
    const name_j = service_class_name orelse return jni.JNI_FALSE;
    const name_chars = jni.getStringUTFChars(env, name_j) orelse return jni.JNI_FALSE;
    defer jni.releaseStringUTFChars(env, name_j, name_chars);

    const restart = cb(name_chars);
    _ = jni.clearPendingException(env);
    return if (restart != 0) jni.JNI_TRUE else jni.JNI_FALSE;
}

//==============================================================================
// JNI exports — GossamerAppWidgetProvider
//==============================================================================

/// `private static native String nativeFetchWidgetState(Context context)`
///
/// Call the app `fetch_state` callback and wrap its JSON in a Java String. With
/// no callback, returns "{}" so the subclass `renderWidget` always has valid
/// (empty) state to parse.
export fn Java_io_gossamer_services_GossamerAppWidgetProvider_nativeFetchWidgetState(
    env: jni.JNIEnv,
    _: jni.jclass,
    context: jni.jobject,
) jni.jstring {
    _ = context;
    const json_ptr: [*:0]const u8 = if (cb_widget_fetch_state) |cb|
        cb(WIDGET_STATE_CAP)
    else
        "{}";
    const result = jni.newStringUTF(env, json_ptr);
    _ = jni.clearPendingException(env);
    return result;
}

/// `private static native void nativeHandleWidgetAction(Context context, String action, int widgetId)`
///
/// Read the action string and dispatch the app `handle_action` callback. No-op
/// when there is no callback or the action is unreadable.
export fn Java_io_gossamer_services_GossamerAppWidgetProvider_nativeHandleWidgetAction(
    env: jni.JNIEnv,
    _: jni.jclass,
    context: jni.jobject,
    action: jni.jstring,
    widget_id: jni.jint,
) void {
    _ = context;
    const cb = cb_widget_handle_action orelse return;
    const action_j = action orelse return;
    const action_chars = jni.getStringUTFChars(env, action_j) orelse return;
    defer jni.releaseStringUTFChars(env, action_j, action_chars);

    cb(action_chars, @intCast(widget_id));
    _ = jni.clearPendingException(env);
}

//==============================================================================
// JNI exports — GossamerActivity (services variant)
//
// The services source set's GossamerActivity adds nativeIntentReceived on top of
// the nativeInit/nativeDestroy already exported by webview_android.zig. (Both
// source sets are alternative builds; an app links exactly one, so this is the
// only definition of nativeIntentReceived and never collides.)
//==============================================================================

/// `private static native void nativeIntentReceived(Intent intent)`
///
/// Build a minimal JSON envelope describing the redelivered Intent — extracting
/// the action via JNI when present — and dispatch the app `on_intent` callback.
export fn Java_io_gossamer_GossamerActivity_nativeIntentReceived(
    env: jni.JNIEnv,
    _: jni.jclass,
    intent: jni.jobject,
) void {
    const cb = cb_intent_on_intent orelse return;

    const action_owned = intentActionOwned(env, intent);
    defer if (action_owned) |a| c_alloc.free(a);

    const json = buildIntentJson(c_alloc, intent != null, if (action_owned) |a| a else null) catch return;
    defer c_alloc.free(json);

    cb(json.ptr);
    _ = jni.clearPendingException(env);
}

/// Build the `nativeIntentReceived` envelope. Separated from the JNI export so
/// it is host-testable (it performs no JNI). Shape:
///   {"hasIntent":true,"action":"android.intent.action.VIEW"}
///   {"hasIntent":true}                 (intent present, no/unknown action)
///   {"hasIntent":false}                (null intent)
fn buildIntentJson(alloc: std.mem.Allocator, has_intent: bool, action: ?[]const u8) ![:0]u8 {
    const has = if (has_intent) "true" else "false";
    if (action) |a| {
        return std.fmt.allocPrintSentinel(
            alloc,
            "{{\"hasIntent\":{s},\"action\":\"{s}\"}}",
            .{ has, a },
            0,
        );
    }
    return std.fmt.allocPrintSentinel(alloc, "{{\"hasIntent\":{s}}}", .{has}, 0);
}

//==============================================================================
// Tests (host-runnable — registry, ServiceHandle lifecycle, JSON helper)
//
// These exercise the pure-Zig surface on a normal CI runner. The JNI exports
// above compile here but are never called (no live JNIEnv on the host).
//==============================================================================

const testing = std.testing;

/// Reset every callback global so tests do not leak registrations into one
/// another. Test-only; not part of the app-facing ABI.
fn resetCallbacksForTest() void {
    cb_service_create = null;
    cb_service_start = null;
    cb_service_destroy = null;
    cb_service_sensor = null;
    cb_widget_fetch_state = null;
    cb_widget_handle_action = null;
    cb_boot_should_restart = null;
    cb_intent_on_intent = null;
}

// --- captured-call probes for the registered callbacks ------------------------

var probe_create_handle: u64 = 0;
var probe_start_calls: u32 = 0;
var probe_sensor_len: u32 = 0;
var probe_sensor_first: f32 = 0;

fn testCreate(handle: u64, config_json: [*:0]const u8) callconv(.c) void {
    probe_create_handle = handle;
    _ = config_json;
}
fn testStartSticky(handle: u64, action: [*:0]const u8, flags: i32, start_id: i32) callconv(.c) i32 {
    _ = handle;
    _ = action;
    _ = flags;
    _ = start_id;
    probe_start_calls += 1;
    return 1; // START_STICKY
}
fn testSensor(handle: u64, sensor_type: i32, values: [*]const f32, len: u32, ts: i64, accuracy: i32) callconv(.c) void {
    _ = handle;
    _ = sensor_type;
    _ = ts;
    _ = accuracy;
    probe_sensor_len = len;
    if (len > 0) probe_sensor_first = values[0];
}
fn testFetchState(out_json_cap: usize) callconv(.c) [*:0]const u8 {
    _ = out_json_cap;
    return "{\"value\":42}";
}
fn testShouldRestart(service_class: [*:0]const u8) callconv(.c) u8 {
    // Restart only the neurophone service; ignore everything else.
    return if (std.mem.eql(u8, std.mem.span(service_class), "io.neurophone.Service")) 1 else 0;
}

test "register_service_callbacks stores all four fn pointers" {
    resetCallbacksForTest();
    gossamer_android_register_service_callbacks(&testCreate, &testStartSticky, null, &testSensor);
    try testing.expect(cb_service_create != null);
    try testing.expect(cb_service_start != null);
    try testing.expect(cb_service_destroy == null); // passed null on purpose
    try testing.expect(cb_service_sensor != null);
}

test "register_widget/boot/intent callbacks store independently" {
    resetCallbacksForTest();
    gossamer_android_register_widget_callbacks(&testFetchState, null);
    gossamer_android_register_boot_callback(&testShouldRestart);
    try testing.expect(cb_widget_fetch_state != null);
    try testing.expect(cb_widget_handle_action == null);
    try testing.expect(cb_boot_should_restart != null);
    try testing.expect(cb_intent_on_intent == null); // never registered
}

test "ServiceHandle alloc copies config, round-trips as a long, and frees" {
    const h = allocServiceHandle("{\"sampleRate\":50}", null) orelse return error.OutOfMemory;
    // Config is copied (owned), NUL-terminated, and matches the input.
    try testing.expectEqualStrings("{\"sampleRate\":50}", std.mem.span(h.config.ptr));
    try testing.expectEqual(@as(u8, 0), h.config[h.config.len]); // sentinel present

    // long round-trip recovers the exact same pointer.
    const as_long = handleToLong(h);
    try testing.expect(as_long > 0);
    const recovered = handleFromLong(as_long) orelse return error.TestUnexpectedResult;
    try testing.expectEqual(h, recovered);

    freeServiceHandle(h);
}

test "handleFromLong rejects non-positive handles" {
    try testing.expect(handleFromLong(0) == null);
    try testing.expect(handleFromLong(-1) == null);
}

test "registered create callback observes the handle id" {
    resetCallbacksForTest();
    gossamer_android_register_service_callbacks(&testCreate, null, null, null);
    probe_create_handle = 0;

    const h = allocServiceHandle("{}", null) orelse return error.OutOfMemory;
    defer freeServiceHandle(h);
    const id: u64 = @intCast(@intFromPtr(h));
    // Simulate the dispatch the JNI create path performs (no JNIEnv needed).
    if (cb_service_create) |cb| cb(id, h.config.ptr);
    try testing.expectEqual(id, probe_create_handle);
}

test "registered start callback returns the START_STICKY code" {
    resetCallbacksForTest();
    gossamer_android_register_service_callbacks(null, &testStartSticky, null, null);
    probe_start_calls = 0;
    const cb = cb_service_start orelse return error.TestUnexpectedResult;
    try testing.expectEqual(@as(i32, 1), cb(1, "android.intent.action.MAIN", 0, 7));
    try testing.expectEqual(@as(u32, 1), probe_start_calls);
}

test "registered sensor callback receives the values pointer and length" {
    resetCallbacksForTest();
    gossamer_android_register_service_callbacks(null, null, null, &testSensor);
    probe_sensor_len = 0;
    probe_sensor_first = 0;
    const samples = [_]f32{ 9.81, 0.0, -0.3 };
    const cb = cb_service_sensor orelse return error.TestUnexpectedResult;
    cb(1, 1, &samples, samples.len, 123456789, 3);
    try testing.expectEqual(@as(u32, 3), probe_sensor_len);
    try testing.expectEqual(@as(f32, 9.81), probe_sensor_first);
}

test "boot callback routes by service class name" {
    resetCallbacksForTest();
    gossamer_android_register_boot_callback(&testShouldRestart);
    const cb = cb_boot_should_restart orelse return error.TestUnexpectedResult;
    try testing.expectEqual(@as(u8, 1), cb("io.neurophone.Service"));
    try testing.expectEqual(@as(u8, 0), cb("io.other.Service"));
}

test "widget fetch_state callback yields its JSON" {
    resetCallbacksForTest();
    gossamer_android_register_widget_callbacks(&testFetchState, null);
    const cb = cb_widget_fetch_state orelse return error.TestUnexpectedResult;
    try testing.expectEqualStrings("{\"value\":42}", std.mem.span(cb(WIDGET_STATE_CAP)));
}

test "buildIntentJson covers null, action-less, and action cases" {
    const a = std.testing.allocator;

    const no_intent = try buildIntentJson(a, false, null);
    defer a.free(no_intent);
    try testing.expectEqualStrings("{\"hasIntent\":false}", no_intent);

    const bare = try buildIntentJson(a, true, null);
    defer a.free(bare);
    try testing.expectEqualStrings("{\"hasIntent\":true}", bare);

    const with_action = try buildIntentJson(a, true, "android.intent.action.VIEW");
    defer a.free(with_action);
    try testing.expectEqualStrings(
        "{\"hasIntent\":true,\"action\":\"android.intent.action.VIEW\"}",
        with_action,
    );
}
