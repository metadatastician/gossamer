// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

use std::env;
use std::path::PathBuf;
use std::process::Command;

const SUPPORTED_ZIG: &str = "0.15.2";

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

fn static_library_name(target: &str) -> &'static str {
    if target.contains("windows") {
        "gossamer.lib"
    } else {
        "libgossamer.a"
    }
}

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
    let version = Command::new(&zig)
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

    let library_dir = PathBuf::from(env::var_os("OUT_DIR").expect("Cargo must set OUT_DIR"))
        .join("gossamer-native");
    std::fs::create_dir_all(&library_dir)
        .unwrap_or_else(|error| panic!("could not create native output directory: {error}"));
    let library = library_dir.join(static_library_name(target));
    let local_cache = library_dir.join("zig-cache");
    let global_cache = library_dir.join("zig-global-cache");

    // Compile only Gossamer objects into the archive. Using the ordinary Zig
    // install step for its static target also archives GTK/WebKit shared
    // objects, which an external Rust linker cannot consume.
    let mut command = Command::new(&zig);
    command
        .current_dir(&source_dir)
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

    validate_prebuilt(library_dir, target)
}

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
