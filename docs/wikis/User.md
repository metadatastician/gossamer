<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Gossamer for app developers

This page is for people **building a desktop app with Gossamer** — not hacking on Gossamer itself. You bring a web frontend (HTML/CSS/JS, or [AffineScript](https://github.com/hyperpolymath/affinescript) → Wasm); Gossamer wraps it in a native window and the compiler proves your backend never leaks a window, connection, or file handle. If you want to work on Gossamer's internals instead, see [Developer](Developer).

Canonical docs live in the repo under [`docs/`](https://github.com/metadatastician/gossamer/tree/main/docs). This wiki is the *signpost*.

## Start here

| If you want to… | Go to |
|---|---|
| Get running in 60 seconds | [docs/QUICKSTART.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/QUICKSTART.adoc) |
| Copy a working starter | [examples/hello/run.sh](https://github.com/metadatastician/gossamer/blob/main/examples/hello/run.sh) |
| Configure your app | [docs/gossamer-conf-reference.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/gossamer-conf-reference.adoc) |
| Understand `let!` linear types | [docs/EPHAPAX-GRAMMAR.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/EPHAPAX-GRAMMAR.adoc) |
| See how Gossamer compares to Tauri/Electron | [README.md#at-a-glance](https://github.com/metadatastician/gossamer/blob/main/README.md#at-a-glance) |

## Prerequisites

Gossamer renders through the **OS webview**, so most of what you install is the native web engine for your platform.

| Platform | Webview | You install |
|---|---|---|
| Linux | WebKitGTK | GTK 3 + WebKitGTK 4.1 dev headers, plus [Zig](https://ziglang.org) |
| macOS | WKWebView | Ships with the OS |
| Windows | WebView2 | WebView2 runtime (bundle it with `webview2: "embed"`) |

On Fedora that's one line:

```bash
sudo dnf install gtk3-devel webkit2gtk4.1-devel zig
```

You also need the **Ephapax compiler** (your backend language) and **Deno** (Gossamer's frontend build runner — npm is not supported). `git` 2.40+ and `just` round out the toolchain.

## 60-second quick start

```bash
# 1. Build the native library (libgossamer)
cd src/interface/ffi && zig build

# 2. Build the Ephapax backend compiler
git clone https://github.com/hyperpolymath/ephapax
cd ephapax && cargo build -p ephapax-cli

# 3. Run the hello example
cd gossamer && bash examples/hello/run.sh
```

Full walkthrough: [docs/QUICKSTART.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/QUICKSTART.adoc).

## The minimal program

Your backend entrypoint is Ephapax. This is the whole "hello window":

```
fn main(): I64 =
  let! window = __ffi("gossamer_create", "My App", 800, 600, 1, 1, 0) in
  let! _      = __ffi("gossamer_load_html", window, "<h1>Hello!</h1>") in
  __ffi("gossamer_run", window)
```

`let!` means `window` is **linear** — it must be used exactly once. Delete the last line and the compiler rejects your program; use `window` again after `gossamer_run` and it rejects your program. No leaked handle can compile. Resources that matter (windows, connections, file handles) use `let!`; everything else uses `let` (use at most once). See [docs/EPHAPAX-GRAMMAR.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/EPHAPAX-GRAMMAR.adoc).

## Configuration: `gossamer.conf.json`

Everything else — windows, security, IPC, packaging — is declared in `gossamer.conf.json` at your project root. It plays the role Tauri's `tauri.conf.json` does. Full field reference: [docs/gossamer-conf-reference.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/gossamer-conf-reference.adoc).

Required top-level fields: `productName`, `version`, `identifier` (reverse-domain). A window and a Content Security Policy:

```json
{
  "productName": "My App",
  "version": "0.1.0",
  "identifier": "com.example.myapp",
  "app": {
    "windows": [{ "label": "main", "title": "My App", "width": 1400, "height": 900 }],
    "security": {
      "csp": "default-src 'self'; script-src 'self'",
      "capabilities": ["filesystem", "network", "clipboard"]
    }
  }
}
```

The CLI auto-loads your `csp` and applies it at runtime (`gossamer_set_csp`). Set `csp` to `null` only during development — never ship it.

## The capability model

Permissions are **allow-list, not deny-list**, and enforced by the compiler-backed capability registry (256 slots) rather than by hoping a JSON typo doesn't open a hole.

| Layer | Where | What it does |
|---|---|---|
| Static capabilities | `security.capabilities` | Gate which IPC command families exist at all — e.g. `filesystem`, `network`, `shell`, `clipboard`, `notification`, `tray`, `dialog` (desktop); `camera`, `geolocation`, `biometric`, `nfc` (mobile) |
| Capability tokens | `security.capabilityTokens` | Optional **time-bounded** grants (`ttl`, `rotateOnFocus`) layered on top of the static list |
| Sandbox | `security.sandbox` | OS-level process limits — `allowExec`, `allowNetwork`, `allowFilesystem`, `allowedPaths` glob allow-list |

If a capability isn't declared, the command family behind it can't be reached — there is no runtime path to bypass it.

## Talking to your frontend (IPC)

The bridge (`window.__gossamer`) is auto-injected when `app.ipc.bridgeInjection` is on. Pick a pattern per call:

| Pattern | Use when | Backend primitive |
|---|---|---|
| **Sync** request/response | fast call, frontend waits for a reply | `gossamer_channel_bind` |
| **Async** request/response | long work you don't want blocking the UI thread | `gossamer_channel_bind_async` (256-slot inflight tracker; replies marshalled back to the UI thread) |
| **Streaming** events | backend pushes to the frontend (progress, live data) | `gossamer_emit` / `gossamer_emit_binary`, with subscribe/unsubscribe on the frontend |

Wire format is set by `app.ipc.protocol` — `json` (default), `msgpack`, or `cbor`. Client helpers ship in the **Rust** binding and the **AffineScript** binding (published as `@gossamer/api`, a Deno ESM module).

## Packaging your app

Build installers for every target with `just`:

| Command | Output |
|---|---|
| `just package-deb` | Debian/Ubuntu `.deb` |
| `just package-rpm` | Fedora/RHEL `.rpm` |
| `just package-flatpak` | Flatpak (universal Linux) |
| `just package-macos` | macOS universal `.dmg` (lipo x64 + arm64) |
| `just package-windows` | Windows `.msi` (WiX) |
| `just package-all` | All of the above |

Bundle metadata (targets, icons, license, per-platform options such as Windows `webview2` embed/download/system) lives under the `bundle` key in `gossamer.conf.json`.

## Common tasks

| I want to… | Do this |
|---|---|
| Add a second window | Append an entry to `app.windows` with a unique `label` |
| Lock down the frontend | Set `app.security.csp` and trim `app.security.capabilities` |
| Let the frontend read files | Add `filesystem` to `capabilities`; scope it with `sandbox.allowedPaths` |
| Stream progress to the UI | Emit named events from the backend with `gossamer_emit` |
| Avoid blocking on a slow call | Bind the handler with `gossamer_channel_bind_async` |
| Ship an installer | Run the matching `just package-*` recipe |
| Migrate from Tauri | Translate `tauri.conf.json` → `gossamer.conf.json` (see the reference's "Differences from Tauri") |

Stuck? Open an issue at [github.com/metadatastician/gossamer/issues](https://github.com/metadatastician/gossamer/issues).
