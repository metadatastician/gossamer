K9!
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
# K9 Kennel-level guard: gossamer project metadata and IPC invariants
# Security Level: Kennel (data-only, no execution)
# No signature required

{
  pedigree = {
    schema_version = "1.0.0",
    component_type = "desktop-framework-metadata",
    security = {
      leash = 'Kennel,
      trust_level = "data-only",
      allow_network = false,
      allow_filesystem_write = false,
      allow_subprocess = false,
    },
    metadata = {
      name = "gossamer-metadata",
      version = "0.3.1",
      description = "Gossamer: universal desktop IPC framework — project invariants",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },
  },

  # Project configuration
  config = {
    # IPC architecture invariants
    ipc = {
      # All IPC must go through Groove protocol
      groove_first = true,
      # Binary IPC must be Zig-implemented
      binary_ipc_language = "zig",
      # Transport types allowed
      transport_types = ["ipc", "tcp", "unix-socket"],
    },

    # Window management invariants
    window_management = {
      required_features = [
        "guard",
        "transmute",
        "activity",
        "grouping",
        "debug",
      ],
    },

    # Safety invariants
    safety = {
      forbidden_patterns = [
        "unwrap()",
        "expect()",
        "todo!()",
        "unimplemented!()",
      ],
    },

    # Test requirements
    tests = {
      min_zig_tests = 20,
      ipc_handler_tests_required = true,
    },

    # Build/runtime
    build = {
      primary_language = "deno",
      zig_binary_ipc = true,
      version = "0.3.1",
    },

    # Language policy
    banned_files = ["Makefile", "Dockerfile"],
    banned_languages = ["python", "typescript", "go"],
  },

  # RSR compliance
  rsr = {
    explainme = true,
    ai_manifest = true,
    machine_readable = true,
    spdx_headers_required = true,
    security_md_required = true,
    idris2_abi = true,
    zig_ffi = true,
  },
}
