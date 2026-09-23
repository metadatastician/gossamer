// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

use std::env;
use std::ffi::{OsStr, OsString};
use std::path::{Path, PathBuf};
use std::process::Command;

const SUPPORTED_ZIG: &str = "0.15.2";

/// Selects or builds the native Gossamer library and emits Cargo linker directives.
///
/// `GOSSAMER_LIB_DIR` selects a prebuilt target library. Without it, native
/// Linux builds compile the library from source, using `GOSSAMER_ZIG` when set.
///
/// # Panics
///
/// Panics when Cargo's target metadata is unavailable, a requested prebuilt
/// library is missing, cross-compilation has no prebuilt library, or native
/// compilation and platform dependency discovery fail.
fn main() {
    println!("cargo:rerun-if-env-changed=GOSSAMER_LIB_DIR");
    println!("cargo:rerun-if-env-changed=GOSSAMER_ZIG");

    let target = env::var("TARGET").expect("Cargo must set TARGET");
    let host = env::var("HOST").expect("Cargo must set HOST");
    let library_dir = match env::var_os("GOSSAMER_LIB_DIR") {
        Some(path) => validate_prebuilt(PathBuf::from(path), &target),
        None => {
            if target != host {
                panic!(
                    "gossamer-rs cannot source-build for cross target {target} from host {host}; \
                     build libgossamer for the target and set GOSSAMER_LIB_DIR"
                );
            }
            build_from_source(&target)
        }
    };

    println!("cargo:rustc-link-search=native={}", library_dir.display());
    println!("cargo:rustc-link-lib=static=gossamer");
    link_platform_dependencies(&target);
}

/// Returns `gossamer.lib` for Windows targets and `libgossamer.a` otherwise.
fn static_library_name(target: &str) -> &'static str {
    if target.contains("windows") {
        "gossamer.lib"
    } else {
        "libgossamer.a"
    }
}

/// Returns `library_dir` after confirming that it contains the target library.
///
/// # Panics
///
/// Panics when the expected static library is not a regular file.
fn validate_prebuilt(library_dir: PathBuf, target: &str) -> PathBuf {
    let library = library_dir.join(static_library_name(target));
    if !library.is_file() {
        panic!(
            "GOSSAMER_LIB_DIR={} does not contain the required static library {}",
            library_dir.display(),
            library.display()
        );
    }
    library_dir
}

/// Builds Gossamer from source into Cargo's output directory for native Linux.
///
/// The build uses Zig plus GTK and WebKitGTK flags from `pkg-config`, then
/// returns the directory containing the verified static library.
///
/// # Panics
///
/// Panics for non-Linux or Android targets, missing Cargo metadata or source,
/// output-directory creation failures, and any Zig or `pkg-config` failure.
fn build_from_source(target: &str) -> PathBuf {
    if !target.contains("linux") || target.contains("android") {
        panic!(
            "gossamer-rs source builds are currently proved only for native Linux; \
             build libgossamer for target {target} and set GOSSAMER_LIB_DIR"
        );
    }

    let manifest_dir = PathBuf::from(
        env::var_os("CARGO_MANIFEST_DIR").expect("Cargo must set CARGO_MANIFEST_DIR"),
    );
    let source_dir = manifest_dir.join("../../src/interface/ffi");
    let build_file = source_dir.join("build.zig");
    if !build_file.is_file() {
        panic!(
            "Gossamer Zig source is unavailable at {}; use the git repository dependency \
             or set GOSSAMER_LIB_DIR to a prebuilt target library",
            build_file.display()
        );
    }

    println!("cargo:rerun-if-changed={}", build_file.display());
    println!(
        "cargo:rerun-if-changed={}",
        source_dir.join("src").display()
    );

    let zig = env::var_os("GOSSAMER_ZIG").unwrap_or_else(|| "zig".into());
    verify_zig_version(&zig);

    let library_dir = PathBuf::from(env::var_os("OUT_DIR").expect("Cargo must set OUT_DIR"))
        .join("gossamer-native");
    std::fs::create_dir_all(&library_dir)
        .unwrap_or_else(|error| panic!("could not create native output directory: {error}"));
    compile_native_library(&zig, &source_dir, &library_dir, target);

    validate_prebuilt(library_dir, target)
}

/// Ensures the configured Zig executable reports the exact supported version.
///
/// # Panics
///
/// Panics when Zig cannot be executed, its version probe fails, or its trimmed
/// version output differs from [`SUPPORTED_ZIG`].
fn verify_zig_version(zig: &OsStr) {
    let version = Command::new(zig)
        .arg("version")
        .output()
        .unwrap_or_else(|error| {
            panic!(
                "could not execute Zig for the Gossamer native build: {error}; \
                 install Zig {SUPPORTED_ZIG} or set GOSSAMER_ZIG"
            )
        });
    if !version.status.success() {
        panic!("Zig version probe failed with status {}", version.status);
    }
    let actual = String::from_utf8_lossy(&version.stdout).trim().to_owned();
    if actual != SUPPORTED_ZIG {
        panic!(
            "Gossamer native source requires Zig {SUPPORTED_ZIG}, found {actual}; \
             set GOSSAMER_ZIG to the exact compiler or provide GOSSAMER_LIB_DIR"
        );
    }
}

/// Compiles the Gossamer Zig sources into `library_dir` for Rust linking.
///
/// GTK and WebKitGTK compiler flags come from `pkg-config`; Zig writes its
/// local and global caches under `library_dir` as part of the build.
///
/// # Panics
///
/// Panics when dependency flags cannot be resolved, Zig cannot be started, or
/// the Zig build exits unsuccessfully.
fn compile_native_library(zig: &OsString, source_dir: &Path, library_dir: &Path, target: &str) {
    let library = library_dir.join(static_library_name(target));
    let local_cache = library_dir.join("zig-cache");
    let global_cache = library_dir.join("zig-global-cache");

    // Compile only Gossamer objects into the archive. Using the ordinary Zig
    // install step for its static target also archives GTK/WebKit shared
    // objects, which an external Rust linker cannot consume.
    let mut command = Command::new(zig);
    command
        .current_dir(source_dir)
        .args([
            "build-lib",
            "src/main.zig",
            "-static",
            "-OReleaseSafe",
            "-fcompiler-rt",
            "-lc",
            "--cache-dir",
        ])
        .arg(&local_cache)
        .arg("--global-cache-dir")
        .arg(&global_cache)
        .arg(format!("-femit-bin={}", library.display()));
    for flag in pkg_config_output("--cflags", &["gtk+-3.0", "webkit2gtk-4.1"]).split_whitespace() {
        if flag == "-pthread" {
            command.arg("-D_REENTRANT");
        } else {
            command.arg(flag);
        }
    }
    let status = command
        .status()
        .unwrap_or_else(|error| panic!("could not start the Gossamer Zig build: {error}"));
    if !status.success() {
        panic!(
            "Gossamer Zig build failed with status {status}; verify the Zig {SUPPORTED_ZIG} \
             toolchain and the native webview development packages for target {target}"
        );
    }
}

/// Emits the native linker directives required by the Cargo target platform.
///
/// Linux uses GTK, WebKitGTK, and `dl`; macOS uses Cocoa and WebKit; Windows
/// uses `ole32`, `user32`, and `kernel32`.
///
/// # Panics
///
/// Panics when a Linux dependency cannot be resolved or the target is not a
/// supported native Linux, macOS, or Windows target.
fn link_platform_dependencies(target: &str) {
    if target.contains("linux") && !target.contains("android") {
        link_pkg_config(&["gtk+-3.0", "webkit2gtk-4.1"]);
        println!("cargo:rustc-link-lib=dylib=dl");
    } else if target.contains("apple-darwin") {
        println!("cargo:rustc-link-lib=framework=Cocoa");
        println!("cargo:rustc-link-lib=framework=WebKit");
    } else if target.contains("windows") {
        for library in ["ole32", "user32", "kernel32"] {
            println!("cargo:rustc-link-lib=dylib={library}");
        }
    } else {
        panic!(
            "gossamer-rs does not yet define native link dependencies for target {target}; \
             use a supported native Linux, macOS, or Windows target"
        );
    }
}

/// Emits Cargo linker directives translated from `pkg-config --libs` output.
///
/// `-L` and `-l` flags become search-path and dynamic-library directives;
/// other flags are forwarded as linker arguments.
///
/// # Panics
///
/// Panics when `pkg-config` cannot resolve `packages`.
fn link_pkg_config(packages: &[&str]) {
    let output = pkg_config_output("--libs", packages);
    for flag in output.split_whitespace() {
        if let Some(path) = flag.strip_prefix("-L") {
            println!("cargo:rustc-link-search=native={path}");
        } else if let Some(library) = flag.strip_prefix("-l") {
            println!("cargo:rustc-link-lib=dylib={library}");
        } else {
            println!("cargo:rustc-link-arg={flag}");
        }
    }
}

/// Runs `pkg-config` with `mode` and `packages`, returning its UTF-8 standard output.
///
/// # Panics
///
/// Panics when `pkg-config` cannot be executed, exits unsuccessfully, or emits
/// non-UTF-8 standard output.
fn pkg_config_output(mode: &str, packages: &[&str]) -> String {
    let output = Command::new("pkg-config")
        .arg(mode)
        .args(packages)
        .output()
        .unwrap_or_else(|error| {
            panic!(
                "could not execute pkg-config for {}: {error}",
                packages.join(", ")
            )
        });
    if !output.status.success() {
        panic!(
            "pkg-config could not resolve {}: {}",
            packages.join(", "),
            String::from_utf8_lossy(&output.stderr).trim()
        );
    }
    String::from_utf8(output.stdout).expect("pkg-config output must be UTF-8")
}
