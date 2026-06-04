// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
fn main() {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")
        .expect("CARGO_MANIFEST_DIR is always set by Cargo when invoking build scripts");
    let lib_path = std::path::Path::new(&manifest_dir).join("../../src/interface/ffi/zig-out/lib");
    
    // Tell cargo to look for libgossamer in the ffi build output directory
    println!("cargo:rustc-link-search=native={}", lib_path.display());
    println!("cargo:rustc-link-lib=gossamer");

    // Also link system dependencies required by WebKitGTK (via gossamer)
    println!("cargo:rustc-link-lib=gtk-3");
    println!("cargo:rustc-link-lib=gdk-3");
    println!("cargo:rustc-link-lib=webkit2gtk-4.1");
}
