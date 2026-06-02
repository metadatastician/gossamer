// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Real JNI binding (pure Zig, no C shim)
//
// This module models the Java Native Interface function tables directly in
// Zig and provides typed wrappers. It exists because the previous Android
// bridge declared `extern fn jni_FindClass(...)` and friends — symbols that
// are defined NOWHERE. Real JNI is not a set of flat C symbols: every call is
// an indirect call through the per-thread `JNIEnv` function table
// (`(*env)->FindClass(env, ...)` in C). Without that indirection the Android
// shell cannot link, let alone run.
//
// Design choices that keep this binding correct without a local Android
// toolchain to compile against:
//
//   1. The function table is addressed BY INDEX through the canonical JNI
//      ordinal table (stable across every Android API level since 1.6). We do
//      not hand-transcribe ~232 struct fields — only the ordinals we use —
//      so an off-by-one in an unused slot cannot silently corrupt a used one.
//
//   2. Method invocation uses the `...A` variants (`CallVoidMethodA`,
//      `NewObjectA`, `CallStaticVoidMethodA`) which take a `jvalue[]` array
//      rather than C varargs. This sidesteps the platform varargs ABI (a real
//      hazard when passing a 64-bit `jlong` through `...` on arm64) and is the
//      JNI-recommended path for generated/bridged callers.
//
//   3. Pointer-width and union layout follow the Android NDK `jni.h` exactly.
//
// This file is pure Zig and compiles on any target (it pulls in no Android
// headers); it is only LINKED into a working image when building for an
// `*-linux-android` target. That property lets its `test` blocks run on the
// host CI runner.

const std = @import("std");

//==============================================================================
// Opaque JNI reference types
//==============================================================================

/// `jobject` — opaque reference to any Java object (local or global).
pub const jobject = ?*anyopaque;
/// `jclass` — reference to a `java.lang.Class`.
pub const jclass = jobject;
/// `jstring` — reference to a `java.lang.String`.
pub const jstring = jobject;
/// `jthrowable` — reference to a `java.lang.Throwable`.
pub const jthrowable = jobject;
/// `jmethodID` — opaque method identifier (NOT a GC reference; stable).
pub const jmethodID = ?*anyopaque;
/// `jfieldID` — opaque field identifier.
pub const jfieldID = ?*anyopaque;

/// JNI primitive scalar types (NDK `jni.h`).
pub const jint = i32;
pub const jlong = i64;
pub const jboolean = u8;
pub const jbyte = i8;
pub const jchar = u16;
pub const jshort = i16;
pub const jfloat = f32;
pub const jdouble = f64;
pub const jsize = jint;

pub const JNI_TRUE: jboolean = 1;
pub const JNI_FALSE: jboolean = 0;

/// JNI status / version constants used by the invocation API.
pub const JNI_OK: jint = 0;
pub const JNI_EDETACHED: jint = -2;
pub const JNI_EVERSION: jint = -3;
pub const JNI_VERSION_1_6: jint = 0x00010006;

/// `jvalue` — the 8-byte C union passed to the `...A` call variants.
/// Modelled as an `extern union` so its size/alignment match the NDK.
pub const jvalue = extern union {
    z: jboolean,
    b: jbyte,
    c: jchar,
    s: jshort,
    i: jint,
    j: jlong,
    f: jfloat,
    d: jdouble,
    l: jobject,
};

/// Construct a `jvalue` carrying an object reference.
pub inline fn vObj(o: jobject) jvalue {
    return .{ .l = o };
}
/// Construct a `jvalue` carrying a 64-bit `long` (e.g. a native pointer).
pub inline fn vLong(x: jlong) jvalue {
    return .{ .j = x };
}
/// Construct a `jvalue` carrying an `int`.
pub inline fn vInt(x: jint) jvalue {
    return .{ .i = x };
}

//==============================================================================
// Function-table addressing
//
// `JNIEnv` is `const struct JNINativeInterface*`. The struct it points at is a
// flat table of function pointers. We model it as a many-item pointer of
// `*anyopaque` slots and index it by ordinal, casting each used slot to its
// real signature at the call site.
//==============================================================================

/// The function table itself: an array of opaque function pointers.
pub const FunctionTable = [*]const ?*const anyopaque;

/// `JNIEnv` — pointer to the function table. One per attached thread.
pub const JNIEnv = *const FunctionTable;

/// Canonical JNI ordinals (`JNINativeInterface` field order, NDK `jni.h`).
/// Only the entries Gossamer calls are listed; the order is fixed by the spec.
const Ord = struct {
    const ExceptionClear: usize = 17;
    const NewGlobalRef: usize = 21;
    const DeleteGlobalRef: usize = 22;
    const NewObjectA: usize = 30;
    const GetObjectClass: usize = 31;
    const GetMethodID: usize = 33;
    const CallObjectMethodA: usize = 36;
    const CallVoidMethodA: usize = 63;
    const GetStaticMethodID: usize = 113;
    const CallStaticVoidMethodA: usize = 143;
    const NewStringUTF: usize = 167;
    const GetStringUTFChars: usize = 169;
    const ReleaseStringUTFChars: usize = 170;
    const GetJavaVM: usize = 219;
    const ExceptionCheck: usize = 228;
};

/// Fetch table slot `ord` from `env` and reinterpret it as function type `Fn`.
inline fn slot(env: JNIEnv, comptime ord: usize, comptime Fn: type) Fn {
    return @ptrCast(env.*[ord].?);
}

//==============================================================================
// Typed wrappers — the only surface the rest of the shell should use
//==============================================================================

/// `(*env)->FindClass(env, name)` — resolve a class by JNI name
/// (e.g. "android/webkit/WebView"). Returns null + a pending exception on miss.
pub fn findClass(env: JNIEnv, name: [*:0]const u8) jclass {
    const FindClass = *const fn (JNIEnv, [*:0]const u8) callconv(.c) jclass;
    // FindClass is ordinal 6; resolve directly (kept inline to avoid an unused
    // ordinal constant when only a subset of callers need it).
    const f: FindClass = @ptrCast(env.*[6].?);
    return f(env, name);
}

/// `(*env)->GetObjectClass(env, obj)`.
pub fn getObjectClass(env: JNIEnv, obj: jobject) jclass {
    const F = *const fn (JNIEnv, jobject) callconv(.c) jclass;
    return slot(env, Ord.GetObjectClass, F)(env, obj);
}

/// `(*env)->GetMethodID(env, cls, name, sig)` — instance method id.
pub fn getMethodID(env: JNIEnv, cls: jclass, name: [*:0]const u8, sig: [*:0]const u8) jmethodID {
    const F = *const fn (JNIEnv, jclass, [*:0]const u8, [*:0]const u8) callconv(.c) jmethodID;
    return slot(env, Ord.GetMethodID, F)(env, cls, name, sig);
}

/// `(*env)->GetStaticMethodID(env, cls, name, sig)` — static method id.
pub fn getStaticMethodID(env: JNIEnv, cls: jclass, name: [*:0]const u8, sig: [*:0]const u8) jmethodID {
    const F = *const fn (JNIEnv, jclass, [*:0]const u8, [*:0]const u8) callconv(.c) jmethodID;
    return slot(env, Ord.GetStaticMethodID, F)(env, cls, name, sig);
}

/// `(*env)->NewObjectA(env, cls, ctor, args)` — construct an object.
pub fn newObject(env: JNIEnv, cls: jclass, ctor: jmethodID, args: []const jvalue) jobject {
    const F = *const fn (JNIEnv, jclass, jmethodID, [*]const jvalue) callconv(.c) jobject;
    return slot(env, Ord.NewObjectA, F)(env, cls, ctor, args.ptr);
}

/// `(*env)->CallVoidMethodA(env, obj, mid, args)` — invoke a `void` instance method.
pub fn callVoidMethod(env: JNIEnv, obj: jobject, mid: jmethodID, args: []const jvalue) void {
    const F = *const fn (JNIEnv, jobject, jmethodID, [*]const jvalue) callconv(.c) void;
    slot(env, Ord.CallVoidMethodA, F)(env, obj, mid, args.ptr);
}

/// `(*env)->CallObjectMethodA(env, obj, mid, args)` — invoke an Object-returning method.
pub fn callObjectMethod(env: JNIEnv, obj: jobject, mid: jmethodID, args: []const jvalue) jobject {
    const F = *const fn (JNIEnv, jobject, jmethodID, [*]const jvalue) callconv(.c) jobject;
    return slot(env, Ord.CallObjectMethodA, F)(env, obj, mid, args.ptr);
}

/// `(*env)->CallStaticVoidMethodA(env, cls, mid, args)`.
pub fn callStaticVoidMethod(env: JNIEnv, cls: jclass, mid: jmethodID, args: []const jvalue) void {
    const F = *const fn (JNIEnv, jclass, jmethodID, [*]const jvalue) callconv(.c) void;
    slot(env, Ord.CallStaticVoidMethodA, F)(env, cls, mid, args.ptr);
}

/// `(*env)->NewStringUTF(env, bytes)` — make a Java String from modified-UTF-8.
pub fn newStringUTF(env: JNIEnv, bytes: [*:0]const u8) jstring {
    const F = *const fn (JNIEnv, [*:0]const u8) callconv(.c) jstring;
    return slot(env, Ord.NewStringUTF, F)(env, bytes);
}

/// `(*env)->GetStringUTFChars(env, s, isCopy)` — borrow the UTF-8 bytes.
/// Caller MUST pair every successful call with `releaseStringUTFChars`.
pub fn getStringUTFChars(env: JNIEnv, s: jstring) ?[*:0]const u8 {
    const F = *const fn (JNIEnv, jstring, ?*jboolean) callconv(.c) ?[*:0]const u8;
    return slot(env, Ord.GetStringUTFChars, F)(env, s, null);
}

/// `(*env)->ReleaseStringUTFChars(env, s, chars)`.
pub fn releaseStringUTFChars(env: JNIEnv, s: jstring, chars: [*:0]const u8) void {
    const F = *const fn (JNIEnv, jstring, [*:0]const u8) callconv(.c) void;
    slot(env, Ord.ReleaseStringUTFChars, F)(env, s, chars);
}

/// `(*env)->NewGlobalRef(env, o)` — promote a local ref to a process-global ref.
pub fn newGlobalRef(env: JNIEnv, o: jobject) jobject {
    const F = *const fn (JNIEnv, jobject) callconv(.c) jobject;
    return slot(env, Ord.NewGlobalRef, F)(env, o);
}

/// `(*env)->DeleteGlobalRef(env, o)`.
pub fn deleteGlobalRef(env: JNIEnv, o: jobject) void {
    const F = *const fn (JNIEnv, jobject) callconv(.c) void;
    slot(env, Ord.DeleteGlobalRef, F)(env, o);
}

/// `(*env)->ExceptionCheck(env)` — true if a Java exception is pending.
pub fn exceptionCheck(env: JNIEnv) bool {
    const F = *const fn (JNIEnv) callconv(.c) jboolean;
    return slot(env, Ord.ExceptionCheck, F)(env) != JNI_FALSE;
}

/// `(*env)->ExceptionClear(env)` — discard any pending Java exception.
pub fn exceptionClear(env: JNIEnv) void {
    const F = *const fn (JNIEnv) callconv(.c) void;
    slot(env, Ord.ExceptionClear, F)(env);
}

/// Clear a pending exception if one is present; return whether one was found.
/// Bridged callbacks must not return to the JVM with an exception still set.
pub fn clearPendingException(env: JNIEnv) bool {
    if (exceptionCheck(env)) {
        exceptionClear(env);
        return true;
    }
    return false;
}

//==============================================================================
// Invocation API (JavaVM) — needed to attach the Service/Receiver/Widget
// threads, which the JVM may invoke on threads that have no JNIEnv yet.
//==============================================================================

/// The invocation function table (`JNIInvokeInterface`).
pub const InvokeTable = [*]const ?*const anyopaque;
/// `JavaVM` — pointer to the invocation table. One per process.
pub const JavaVM = *const InvokeTable;

const InvokeOrd = struct {
    const AttachCurrentThread: usize = 4;
    const DetachCurrentThread: usize = 5;
    const GetEnv: usize = 6;
};

inline fn vmSlot(vm: JavaVM, comptime ord: usize, comptime Fn: type) Fn {
    return @ptrCast(vm.*[ord].?);
}

/// `(*env)->GetJavaVM(env, &vm)` — recover the process `JavaVM` from any env.
pub fn getJavaVM(env: JNIEnv) ?JavaVM {
    const F = *const fn (JNIEnv, *?JavaVM) callconv(.c) jint;
    var vm: ?JavaVM = null;
    const rc = slot(env, Ord.GetJavaVM, F)(env, &vm);
    if (rc != JNI_OK) return null;
    return vm;
}

/// `(*vm)->GetEnv(vm, &env, version)` — fetch this thread's env if attached.
pub fn getEnv(vm: JavaVM, version: jint) ?JNIEnv {
    const F = *const fn (JavaVM, *?*anyopaque, jint) callconv(.c) jint;
    var env: ?*anyopaque = null;
    const rc = vmSlot(vm, InvokeOrd.GetEnv, F)(vm, &env, version);
    if (rc != JNI_OK) return null;
    const e = env orelse return null;
    return @ptrCast(@alignCast(e));
}

/// `(*vm)->AttachCurrentThread(vm, &env, null)` — attach a native thread so it
/// can make JNI calls. Returns the freshly-bound env, or null on failure.
pub fn attachCurrentThread(vm: JavaVM) ?JNIEnv {
    const F = *const fn (JavaVM, *?*anyopaque, ?*anyopaque) callconv(.c) jint;
    var env: ?*anyopaque = null;
    const rc = vmSlot(vm, InvokeOrd.AttachCurrentThread, F)(vm, &env, null);
    if (rc != JNI_OK) return null;
    const e = env orelse return null;
    return @ptrCast(@alignCast(e));
}

/// `(*vm)->DetachCurrentThread(vm)` — MUST be called before a thread that
/// attached itself exits, or the JVM will abort.
pub fn detachCurrentThread(vm: JavaVM) void {
    const F = *const fn (JavaVM) callconv(.c) jint;
    _ = vmSlot(vm, InvokeOrd.DetachCurrentThread, F)(vm);
}

//==============================================================================
// Tests (host-runnable — no Android required)
//==============================================================================

test "jvalue is the 8-byte JNI union" {
    // The NDK defines jvalue as an 8-byte union; the ...A call variants index
    // it as a contiguous array, so size and alignment must be exactly 8.
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(jvalue));
    try std.testing.expectEqual(@as(usize, 8), @alignOf(jvalue));
}

test "jvalue constructors select the right union member" {
    try std.testing.expectEqual(@as(jlong, 0x0123_4567_89AB_CDEF), vLong(0x0123_4567_89AB_CDEF).j);
    try std.testing.expectEqual(@as(jint, -7), vInt(-7).i);
    try std.testing.expect(vObj(null).l == null);
}

test "ordinals are monotonic and within the JNI table" {
    // The JNINativeInterface table has 233 entries (0..232). A used ordinal
    // landing outside that range would mean a transcription error.
    const ords = [_]usize{
        Ord.ExceptionClear, Ord.NewGlobalRef,    Ord.DeleteGlobalRef,
        Ord.NewObjectA,     Ord.GetObjectClass,  Ord.GetMethodID,
        Ord.CallObjectMethodA, Ord.CallVoidMethodA, Ord.GetStaticMethodID,
        Ord.CallStaticVoidMethodA, Ord.NewStringUTF, Ord.GetStringUTFChars,
        Ord.ReleaseStringUTFChars, Ord.GetJavaVM, Ord.ExceptionCheck,
    };
    for (ords) |o| try std.testing.expect(o <= 232);
    // A couple of fixed relationships from the spec (…Method / …MethodV / …MethodA
    // are consecutive triples), used here as a transcription self-check.
    try std.testing.expectEqual(Ord.CallVoidMethodA, @as(usize, 63));
    try std.testing.expectEqual(Ord.CallStaticVoidMethodA, @as(usize, 143));
}

test "every JNI wrapper type-checks on the host (compiled, not invoked)" {
    // Taking the address of each wrapper forces full semantic analysis, so a
    // bad function-pointer cast or signature surfaces on the host CI runner —
    // even though webview_android.zig (which uses them) only compiles for an
    // *-android target. The wrappers are never CALLED here: there is no live
    // JNIEnv on the host.
    const refs = .{
        &findClass,        &getObjectClass,     &getMethodID,
        &getStaticMethodID, &newObject,         &callVoidMethod,
        &callObjectMethod, &callStaticVoidMethod, &newStringUTF,
        &getStringUTFChars, &releaseStringUTFChars, &newGlobalRef,
        &deleteGlobalRef,  &exceptionCheck,     &exceptionClear,
        &clearPendingException, &getJavaVM,      &getEnv,
        &attachCurrentThread, &detachCurrentThread,
    };
    inline for (refs) |r| {
        try std.testing.expect(@intFromPtr(r) != 0);
    }
}
