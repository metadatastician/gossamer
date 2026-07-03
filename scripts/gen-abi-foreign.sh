#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# gen-abi-foreign.sh — generate the complete raw %foreign mirror of the
# libgossamer C ABI (Gossamer.ABI.ForeignGen) from the Zig `export fn`
# declarations, making the Zig FFI the SINGLE SOURCE OF TRUTH for the ABI
# (gossamer#82). Bash + AWK (Python is estate-banned).
#
# Usage:
#   scripts/gen-abi-foreign.sh            # write src/interface/abi/ForeignGen.idr
#   scripts/gen-abi-foreign.sh --check    # exit 1 if the committed file is stale
#
# Type mapping (position-aware) mirrors the hand-curated Gossamer.ABI.Foreign,
# which is proven to typecheck: integers -> Bits of same width, C string ->
# String (parameter) / Bits64 (char* return), pointers & function pointers ->
# Bits64, Result/c_int -> Bits32, void -> (), every call wrapped in PrimIO.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
OUT="src/interface/abi/ForeignGen.idr"

read -r -d '' HEADER <<'EOF' || true
-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| GENERATED FILE — DO NOT EDIT BY HAND.
||| Regenerate with `just abi-gen` (scripts/gen-abi-foreign.sh); CI fails if this
||| file is stale (scripts/check-abi-ffi-cleave.sh runs it with --check).
|||
||| Complete raw %foreign mirror of the libgossamer C ABI: EVERY `export fn
||| gossamer_*` in src/interface/ffi/src/*.zig has a matching declaration here,
||| so the Idris ABI describes the *real, whole* FFI surface (gossamer#82) and is
||| generated FROM it — it cannot drift or go phantom. Curated safe wrappers over
||| the core subset live in `Gossamer.ABI.Foreign`; these are the raw bindings.

module Gossamer.ABI.ForeignGen

%default total
EOF

# AWK parses every `export fn gossamer_*` (accumulating multi-line signatures up
# to the body `{`) and prints one "symbol<TAB>idris-signature" line per export.
gen_body() {
  awk '
    function strip(s){ sub(/\/\/.*/,"",s); gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    function map(z, isret,    nz, bare){
      z=strip(z); sub(/,$/,"",z); gsub(/^[ \t]+|[ \t]+$/,"",z)
      if (z=="") return "()"
      nz=z; gsub(/ /,"",nz)
      if (index(nz,"fn(")>0) return "Bits64"
      if (z=="[*:0]const u8"||z=="?[*:0]const u8"||z=="[*c]const u8"||z=="?[*c]const u8")
        return isret ? "Bits64" : "String"
      if (z ~ /^\??\*/ || z ~ /^\??\[\*/) return "Bits64"
      if (z=="void") return "()"
      if (z=="bool"||z=="u8"||z=="i8") return "Bits8"
      if (z=="u16"||z=="i16") return "Bits16"
      if (z=="u32"||z=="i32"||z=="c_int"||z=="c_uint") return "Bits32"
      if (z=="u64"||z=="i64"||z=="usize"||z=="isize"||z=="c_long"||z=="c_ulong") return "Bits64"
      if (z=="f32"||z=="f64") return "Double"
      if (z=="Result" || z ~ /\.Result$/) return "Bits32"
      bare=z; sub(/^\?/,"",bare)
      if (bare ~ /Fn$/) return "Bits64"
      printf("gen-abi-foreign: unmapped Zig type %s\n", z) > "/dev/stderr"; EXIT=1; return "Bits64"
    }
    # split s on TOP-LEVEL commas (paren/bracket-depth aware, so a callback
    # param like `?*const fn(a: T, b: U) callconv(.c) void` stays one element).
    function split_top(s, arr,    i, c, depth, cur, n){
      depth=0; cur=""; n=0
      for (i=1;i<=length(s);i++){
        c=substr(s,i,1)
        if (c=="("||c=="["||c=="{") depth++
        else if (c==")"||c=="]"||c=="}") depth--
        if (c=="," && depth==0){ arr[++n]=cur; cur="" } else cur=cur c
      }
      if (cur ~ /[^ \t]/) arr[++n]=cur
      return n
    }
    function emit(buf,    name, popen, pclose, i, c, depth, params, ret, n, arr, sig, t){
      if (match(buf, /gossamer_[A-Za-z0-9_]+/)==0) return
      name=substr(buf, RSTART, RLENGTH)
      popen=index(buf, "(")                       # first ( = param-list open
      depth=0; pclose=0
      for (i=popen; i<=length(buf); i++){         # scan for its MATCHING close paren
        c=substr(buf,i,1)
        if (c=="(") depth++
        else if (c==")"){ depth--; if (depth==0){ pclose=i; break } }
      }
      params=substr(buf, popen+1, pclose-popen-1)
      ret=substr(buf, pclose+1)                   # after the param list
      sub(/callconv\([^)]*\)/, "", ret)           # drop callconv(...)
      ret=substr(ret, 1, index(ret,"{")>0 ? index(ret,"{")-1 : length(ret))
      ret=strip(ret); if (ret=="") ret="void"
      sig=""
      n=split_top(params, arr)
      for (i=1;i<=n;i++){
        t=arr[i]; sub(/^[^:]*:/, "", t)           # drop "name:" -> TYPE
        if (strip(t)!="") sig = sig map(t,0) " -> "
      }
      print name "\t" sig "PrimIO " map(ret,1)
    }
    /export fn gossamer_/ { collecting=1; buf="" }
    collecting {
      buf = buf " " $0
      if (index($0,"{")>0){ emit(buf); collecting=0 }
    }
    END { if (EXIT) exit 1 }
  ' src/interface/ffi/src/*.zig
}

render() {
  printf '%s\n' "$HEADER"
  # sort by symbol (unique), format each as a 3-line %foreign block
  gen_body | sort -u -t$'\t' -k1,1 | while IFS=$'\t' read -r name sig; do
    [ -z "$name" ] && continue
    printf '\nexport\n%%foreign "C:%s, libgossamer"\nprim__%s : %s\n' "$name" "$name" "$sig"
  done
}

if [ "${1:-}" = "--check" ] || [ "${1:-}" = "--check-generated" ]; then
  if ! diff -q <(render) "$OUT" >/dev/null 2>&1; then
    echo "::error::ForeignGen.idr is stale — run \`just abi-gen\` and commit (the Zig FFI surface changed but the generated ABI mirror did not)." >&2
    exit 1
  fi
  echo "ForeignGen.idr is up to date with the Zig FFI surface."
else
  render > "$OUT"
  echo "wrote $OUT ($(grep -c '%foreign' "$OUT") %foreign declarations)"
fi
