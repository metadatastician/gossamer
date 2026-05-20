;; Hand-rolled hello-world cli.wasm for the launcher MVP.
;;
;; Stands in for the eventual ephapax-compiled output of cli/src/Main.eph
;; (which lands in 14a.5c). Imports the 5 baseline env:: symbols that
;; the launcher provides, exports `main` for the launcher to invoke, and
;; exports `memory` so the launcher can resolve guest pointer arguments
;; for print_string / argv_arg_get.
;;
;; What main does:
;;   1. Calls env::argv_count(), gets the integer back.
;;   2. Prints the count via env::print_i32.
;;   3. For each i in 0..count:
;;        a. Calls env::argv_arg_len(i) to size the next argument.
;;        b. Calls env::argv_arg_get(i, BUF, sizeof BUF) to copy it.
;;        c. Calls env::print_string(BUF, returned_length).
;;   4. Returns.
;;
;; Build: `wat2wasm hello.wat -o hello.wasm`  (wabt package)
;; Run:   `gossamer-launcher hello.wasm one two three`
;; Expect:
;;   3
;;   onetwothree
;;
;; SPDX-License-Identifier: PMPL-1.0-or-later
;; Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

(module
  (import "env" "print_i32"    (func $print_i32    (param i32)))
  (import "env" "print_string" (func $print_string (param i32 i32)))
  (import "env" "argv_count"   (func $argv_count   (result i32)))
  (import "env" "argv_arg_len" (func $argv_arg_len (param i32) (result i32)))
  (import "env" "argv_arg_get" (func $argv_arg_get (param i32 i32 i32) (result i32)))

  ;; Single page of linear memory exported as "memory" so the launcher
  ;; can write argv bytes into a buffer at offset BUF.
  (memory (export "memory") 1)

  ;; Scratch buffer for argv_arg_get — 1024 bytes starting at offset 16.
  (global $BUF i32 (i32.const 16))
  (global $BUF_LEN i32 (i32.const 1024))

  (func (export "main")
    (local $count i32)
    (local $i i32)
    (local $written i32)

    ;; print_i32(argv_count())
    (local.set $count (call $argv_count))
    (call $print_i32 (local.get $count))

    ;; for i in 0..count: write argv[i] into BUF, print_string(BUF, written)
    (local.set $i (i32.const 0))
    (block $exit
      (loop $next
        (br_if $exit (i32.ge_s (local.get $i) (local.get $count)))

        (local.set $written
          (call $argv_arg_get
            (local.get $i)
            (global.get $BUF)
            (global.get $BUF_LEN)))

        ;; Skip on -1 (overflow / bad index), but otherwise print.
        (if (i32.ge_s (local.get $written) (i32.const 0))
          (then
            (call $print_string
              (global.get $BUF)
              (local.get $written))))

        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $next))))
)
