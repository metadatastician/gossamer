#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Point this clone's git hooks at .githooks/ so the local Dogfood Gate runs
# on push. Idempotent; safe to re-run.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath .githooks
chmod +x .githooks/pre-push .githooks/validate-a2ml.sh .githooks/validate-k9.sh 2>/dev/null || true
echo "Installed: core.hooksPath -> .githooks (pre-push A2ML+K9 gate active)."
