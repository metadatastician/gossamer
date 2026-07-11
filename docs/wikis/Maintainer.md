<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Maintainer

You own releases, governance, CI, and the machine-readable state. This page is the *signpost* — the canonical governance docs live in [`docs/governance/`](https://github.com/hyperpolymath/gossamer/tree/main/docs/governance) and the machine-readable files under [`.machine_readable/`](https://github.com/hyperpolymath/gossamer/tree/main/.machine_readable). Edit wiki pages in [`docs/wikis/`](https://github.com/hyperpolymath/gossamer/tree/main/docs/wikis) in the code repo, never in the forge wiki UI (see [Wiki sync](#wiki-sync)).

## Maintainer's map

| Concern | Canonical source |
|---|---|
| Readiness grading (CRG) | [CRG-CRITERIA.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/CRG-CRITERIA.adoc), [CRG-AUDIT-2026-04-18.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/CRG-AUDIT-2026-04-18.adoc) |
| Maintenance runbook | [MAINTENANCE-CHECKLIST.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/MAINTENANCE-CHECKLIST.adoc) |
| Methodology (three axes) | [TSDM.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/TSDM.adoc), [SOFTWARE-DEVELOPMENT-APPROACH.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/SOFTWARE-DEVELOPMENT-APPROACH.adoc) |
| Contractile gates | [`.machine_readable/contractiles/`](https://github.com/hyperpolymath/gossamer/tree/main/.machine_readable/contractiles) + [INDEX.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/contractiles/INDEX.a2ml) |
| Project state | [descriptiles/STATE.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/STATE.a2ml) |
| Release / ops runbook | [descriptiles/PLAYBOOK.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/PLAYBOOK.a2ml) |
| Packaging | [Justfile](https://github.com/hyperpolymath/gossamer/blob/main/Justfile) (`package-*`) |
| Ownership | [MAINTAINERS.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/attribution/MAINTAINERS.adoc), [CODEOWNERS.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/attribution/CODEOWNERS.adoc) |
| Security | `SECURITY.md`, [THREAT-MODEL.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/architecture/THREAT-MODEL.adoc) |
| Changelog | [CHANGELOG.md](https://github.com/hyperpolymath/gossamer/blob/main/CHANGELOG.md) |

## Governance model — CRG D → C

Gossamer grades its own components on the **Component Readiness Grades** scale (see [CRG-CRITERIA.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/CRG-CRITERIA.adoc)). Current grade is **D** (*Partial / Alpha*), target **C** (*Self-Validated* — reliable when dogfooded). The D→C work is in flight: 16 per-directory `README.adoc` files added across the source/build/test subtrees, and dogfooding evidence populated (the `gossamer-mcp` boj-server cartridge; IDApTIK's Tauri→Gossamer migration as the named consumer). C is claimed only once CI is green on that evidence — grade honesty is the rule, not aspiration. `just crg-grade` and `just crg-badge` surface the current grade.

Every maintenance cycle runs the three-axis model ([TSDM.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/TSDM.adoc) / [SOFTWARE-DEVELOPMENT-APPROACH.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/SOFTWARE-DEVELOPMENT-APPROACH.adoc)), in order:

- **Axis 1 — Scope:** `must > intend > like`
- **Axis 2 — Maintenance:** `corrective > adaptive > perfective`
- **Axis 3 — Audit:** `systems > compliance > effects`

Follow [MAINTENANCE-CHECKLIST.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/MAINTENANCE-CHECKLIST.adoc) for the full runbook — marker scan (`TODO/FIXME/XXX/HACK/STUB/PARTIAL`), the Idris `believe_me`/`assert_total` unsoundness scan, the `panic-attack` compliance scan (`just assail`), and benchmarked effects evidence with an explicit maintainer review.

## Contractile governance — the six verbs

Machine-checkable governance lives in [`.machine_readable/contractiles/`](https://github.com/hyperpolymath/gossamer/tree/main/.machine_readable/contractiles) as **six verbs**, each a trident (`{Verbfile}.a2ml` + `{verb}.ncl` + `{verb}.k9.ncl`); [INDEX.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/contractiles/INDEX.a2ml) is the registry consumers read. Top-level summaries [`MUST.contractile`](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/MUST.contractile), [`TRUST.contractile`](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/TRUST.contractile), `INTENT.contractile`, and `ADJUST.contractile` sit at the `.machine_readable/` root.

| Verb | Semantics | Authority | Gate |
|---|---|---|---|
| `must` | Persistent invariants (file presence, SPDX, no unannotated `believe_me`) | blocking | hard |
| `trust` | Secrets, provenance, container security | blocking | hard |
| `bust` | Failure modes + recovery paths | blocking | hard |
| `adjust` | Drift tolerances + corrective actions | advisory | warn |
| `dust` | Hygiene — stale files, format duplicates, artifacts | advisory | warn |
| `intend` | North star — committed next-actions + horizon aspirations | reporting | non-gating |

The `must` gate is release-blocking: SPDX header on every source file, linearly-typed webview handles, ABI defs in Idris2 / FFI in Zig, generated code confined to `generated/`, and every GitHub Action SHA-pinned. Sanctioned proof exceptions (the class-J `%unsafe` axiom) are annotated and documented — unannotated `believe_me`/`assert_total` fail closed.

## Machine-readable state — descriptiles

Update these each session so the human docs and machine docs agree (Axis 3 compliance). They are the honest checkpoint a release reads from:

| File | Holds |
|---|---|
| [STATE.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/STATE.a2ml) | version, CRG grade, phase, MVP milestones, dated session history |
| [META.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/META.a2ml) | languages, licence, build/CI/container/package tooling, the axes |
| [ECOSYSTEM.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/ECOSYSTEM.a2ml) | related projects, integration points |
| [PLAYBOOK.a2ml](https://github.com/hyperpolymath/gossamer/blob/main/.machine_readable/descriptiles/PLAYBOOK.a2ml) | deployment, incident response, release process |

## Release & packaging

The release runbook is `PLAYBOOK.a2ml [release-process]`: bump the version in `STATE.a2ml`, `META.a2ml`, and the `Justfile`; run preflight (validate + quality + security + maintenance hard-pass); tag and push. The changelog is generated (git-cliff, Keep a Changelog, Semantic Versioning) into [CHANGELOG.md](https://github.com/hyperpolymath/gossamer/blob/main/CHANGELOG.md).

Packaging recipes ([Justfile](https://github.com/hyperpolymath/gossamer/blob/main/Justfile)) all build on `build-ffi-release` + `build-launcher-release`:

| Target | Recipe |
|---|---|
| Debian/Ubuntu `.deb` | `just package-deb` |
| Fedora/RHEL `.rpm` | `just package-rpm` |
| Flatpak bundle | `just package-flatpak` |
| macOS DMG/pkg | `just package-macos` |
| Windows MSI (WiX 4) | `just package-windows` |
| Linux CI set | `just package-all` |

Deployment defaults to **guix** (`META.a2ml` `package-manager`), with nix as the fallback shard.

## CI / workflow hygiene

- Keep every GitHub Action **SHA-pinned**; do not remove a workflow without recorded approval (`MUST.contractile`).
- Required gates stay green: **Ephapax Linearity Gate** (`just eph-check` — proves that leaking a `let!` handle is a compile error), **ABI Typecheck Gate + ABI↔FFI cleave** (`just abi-check`, idris2 0.8.0), plus licence-consistency, trusted-base, dogfood-gate, and Hypatia.
- `Gossamer.ABI.ForeignGen` is **generated** — after any Zig FFI export change, run `just abi-gen` and commit; the cleave gate fails on a stale mirror (it mirrors 100% of the `gossamer_*` C surface, so the typechecked ABI cannot drift from the FFI).

## Ownership & security

- Ownership follows the perimeter model in [MAINTAINERS.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/attribution/MAINTAINERS.adoc) / [CODEOWNERS.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/attribution/CODEOWNERS.adoc); the automatic review rules live in `.github/CODEOWNERS`.
- Vulnerability reports follow the repo `SECURITY.md`; the STRIDE analysis is in [THREAT-MODEL.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/architecture/THREAT-MODEL.adoc). Secrets, provenance, and container security are the `trust` contractile's hard gate.

## Wiki sync

[`docs/wikis/`](https://github.com/hyperpolymath/gossamer/tree/main/docs/wikis) is the **single source of truth**. Edit the Markdown here, then publish to the forge-hosted wiki with `just wiki-sync` — never hand-edit pages in the GitHub wiki UI, as the sync overwrites them.

## Release checklist

Work `PLAYBOOK.a2ml [release-process]` together with the Must/Should/Could finish-off pass in [MAINTENANCE-CHECKLIST.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/governance/MAINTENANCE-CHECKLIST.adoc) before you tag. Fail closed: if evidence is missing for any item, treat it as NOT DONE.

---

See also: [Home](Home) · [Developer](Developer) · [Glossary](Glossary)
