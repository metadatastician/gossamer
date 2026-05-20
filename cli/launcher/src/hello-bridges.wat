;; Smoke test for the 14a.5b libgossamer bridges.
;;
;; Calls env::gossamer_version_to(buf, buf_len) to copy libgossamer's
;; version string into a guest buffer, then prints it via the baseline
;; env::print_string(buf, len).
;;
;; This wat covers ONE of the 29 bridges — enough to prove libgossamer
;; is linked, the C ABI marshalling works, and the WASI-style "write
;; into guest buffer" pattern returns the right length.
;;
;; Build: `wasm-tools parse hello-bridges.wat -o hello-bridges.wasm`
;; Run:   `gossamer-launcher hello-bridges.wasm`
;; Expect (something like): `0.3.0` followed by exit.
;;
;; SPDX-License-Identifier: PMPL-1.0-or-later
;; Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

(module
  (import "env" "print_string"        (func $print_string (param i32 i32)))
  (import "env" "gossamer_version_to" (func $version_to   (param i32 i32) (result i32)))

  (memory (export "memory") 1)

  (global $BUF i32 (i32.const 16))
  (global $BUF_LEN i32 (i32.const 256))

  (func (export "main")
    (local $len i32)

    ;; Ask libgossamer to write its version into BUF.
    (local.set $len
      (call $version_to (global.get $BUF) (global.get $BUF_LEN)))

    ;; Print only when the bridge returned a non-negative length.
    (if (i32.ge_s (local.get $len) (i32.const 0))
      (then
        (call $print_string (global.get $BUF) (local.get $len)))))
)
