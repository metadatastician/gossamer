#!/usr/bin/env python3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# gen-abi-foreign.py — generate the complete raw %foreign mirror of the
# libgossamer C ABI (Gossamer.ABI.ForeignGen) from the Zig `export fn`
# declarations. This makes the Zig FFI the SINGLE SOURCE OF TRUTH for the ABI
# surface (gossamer#82): the Idris ABI can no longer drift from — or lie about —
# the real exports, because it is generated from them and checked fresh in CI.
#
# Usage:
#   scripts/gen-abi-foreign.py            # write src/interface/abi/ForeignGen.idr
#   scripts/gen-abi-foreign.py --check    # exit 1 if the committed file is stale
#
# Type mapping (position-aware) mirrors the hand-curated Gossamer.ABI.Foreign,
# which is proven to typecheck: integers -> Bits of the same width, C strings ->
# String as a parameter / Bits64 (char* pointer) as a return, all pointers and
# function pointers -> Bits64, void -> (), every call wrapped in PrimIO.
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FFI_GLOB = os.path.join(ROOT, "src/interface/ffi/src/*.zig")
OUT = os.path.join(ROOT, "src/interface/abi/ForeignGen.idr")

# Integer / scalar Zig types -> Idris Bits* (bit-accurate; signedness is a
# wrapper concern, and the curated Foreign.idr proves Bits* work over %foreign).
SCALAR = {
    "void": "()",
    "bool": "Bits8",
    "u8": "Bits8", "i8": "Bits8",
    "u16": "Bits16", "i16": "Bits16",
    "u32": "Bits32", "i32": "Bits32", "c_int": "Bits32", "c_uint": "Bits32",
    "u64": "Bits64", "i64": "Bits64", "usize": "Bits64", "isize": "Bits64",
    "c_long": "Bits64", "c_ulong": "Bits64",
    "f32": "Double", "f64": "Double",
}
CSTR = {"[*:0]const u8", "?[*:0]const u8", "[*c]const u8", "?[*c]const u8"}


def strip_comment(s: str) -> str:
    return re.sub(r"//.*$", "", s).strip()


def map_type(z: str, is_return: bool) -> str:
    z = strip_comment(z).rstrip(",").strip()
    if not z:
        return "()"
    nospace = z.replace(" ", "")
    # function pointer (callback) -> raw pointer value
    if "fn(" in nospace:
        return "Bits64"
    # C strings: String as a parameter, char* pointer (Bits64) as a return
    if z in CSTR:
        return "Bits64" if is_return else "String"
    # any other pointer / many-item pointer / slice / optional pointer -> Bits64
    if re.match(r"^\??\*", z) or re.match(r"^\??\[\*", z):
        return "Bits64"
    if z in SCALAR:
        return SCALAR[z]
    # Named enums backed by c_int (the Result enum, possibly module-qualified).
    if z == "Result" or z.endswith(".Result"):
        return "Bits32"
    # Named function-pointer typedefs (Zig convention: `*Fn` / `?*Fn`) -> pointer.
    bare = z[1:].strip() if z.startswith("?") else z
    if bare.endswith("Fn"):
        return "Bits64"
    # Unknown type — fail loudly rather than emit a silent wrong binding.
    raise SystemExit(f"gen-abi-foreign: unmapped Zig type {z!r} — extend SCALAR/rules")


def split_params(param_src: str):
    """Split a Zig parameter list on top-level commas (paren-depth aware, so
    function-pointer params like `?*const fn(...) callconv(.c) void` stay whole)."""
    out, depth, cur = [], 0, ""
    for ch in param_src:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return [p for p in (x.strip() for x in out) if p]


def param_type(p: str) -> str:
    # "name: TYPE"  ->  TYPE   (a param has exactly one top-level colon)
    m = re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*:\s*(.+)$", strip_comment(p), re.S)
    return (m.group(1) if m else p).strip()


def parse_exports(text: str):
    """Yield (symbol, [param_types], return_type) for each `export fn gossamer_*`,
    scanning balanced parens so multi-line and callback signatures parse cleanly."""
    for m in re.finditer(r"(?:pub\s+)?export\s+fn\s+(gossamer_[A-Za-z0-9_]+)\s*\(", text):
        name = m.group(1)
        i = m.end()          # just past the '('
        depth, start = 1, i
        while i < len(text) and depth:
            if text[i] == "(":
                depth += 1
            elif text[i] == ")":
                depth -= 1
            i += 1
        params_src = text[start:i - 1]
        rest = text[i:]
        rm = re.match(r"\s*(?:callconv\([^)]*\)\s*)?([^\{;]+?)\s*\{", rest, re.S)
        ret = strip_comment(rm.group(1)) if rm else "void"
        yield name, [param_type(p) for p in split_params(params_src)], ret


def idris_sig(params, ret) -> str:
    pts = [map_type(p, False) for p in params]
    r = map_type(ret, True)
    arrow = "".join(f"{t} -> " for t in pts)
    return f"{arrow}PrimIO {r}"


HEADER = """-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| GENERATED FILE — DO NOT EDIT BY HAND.
||| Regenerate with `just abi-gen` (scripts/gen-abi-foreign.py); CI fails if this
||| file is stale (scripts/check-abi-ffi-cleave.sh --check-generated).
|||
||| Complete raw %foreign mirror of the libgossamer C ABI: EVERY `export fn
||| gossamer_*` in src/interface/ffi/src/*.zig has a matching declaration here,
||| so the Idris ABI describes the *real, whole* FFI surface (gossamer#82) and is
||| generated FROM it — it cannot drift or go phantom. Curated safe wrappers over
||| the core subset live in `Gossamer.ABI.Foreign`; these are the raw bindings.

module Gossamer.ABI.ForeignGen

%default total
"""


def generate() -> str:
    syms = {}
    for path in sorted(glob.glob(FFI_GLOB)):
        with open(path, encoding="utf-8") as f:
            for name, params, ret in parse_exports(f.read()):
                syms[name] = (params, ret)  # last def wins; symbols are unique
    lines = [HEADER]
    for name in sorted(syms):
        params, ret = syms[name]
        lines.append(f'export\n%foreign "C:{name}, libgossamer"\n'
                     f'prim__{name} : {idris_sig(params, ret)}\n')
    return "\n".join(lines) + "\n" if False else "\n".join(lines).rstrip() + "\n"


def main():
    content = generate()
    if "--check" in sys.argv or "--check-generated" in sys.argv:
        try:
            with open(OUT, encoding="utf-8") as f:
                current = f.read()
        except FileNotFoundError:
            current = None
        if current != content:
            print("::error::ForeignGen.idr is stale — run `just abi-gen` and commit "
                  "(the Zig FFI surface changed but the generated ABI mirror did not).",
                  file=sys.stderr)
            sys.exit(1)
        print("ForeignGen.idr is up to date with the Zig FFI surface.")
        return
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(content)
    n = content.count("%foreign")
    print(f"wrote {OUT} ({n} %foreign declarations)")


if __name__ == "__main__":
    main()
