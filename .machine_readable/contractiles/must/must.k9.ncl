K9!
# SPDX-License-Identifier: MPL-2.0
# must.k9.ncl — K9 trust-tier component of the must trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + must.ncl (runner).
# Trident completeness is a hard precondition — a repo shipping
# Mustfile without this file AND its runner is an invalid trident;
# the contractile CLI's verify gate refuses partial publication.
#
# Verb:       must            (invariant assertion — release-blocking)
# Tier:       Hunt-read-only  (capability: subprocess probes shell out
#                              for grep/test/file-check; no mutation;
#                              no network; no write)
# Authority:  blocking        (HARD GATE — the canonical gating verb)
#
# must is the concrete + persistent verb — release-blocking invariants
# that must hold. Complement to trust (concrete + ephemeral). Together
# must + trust form the blocking-authority pair in the contractile set.
#
# Cardinality: ONE must trident per repo.
#
# Failure-mode focus: must is the primary catchment for subtle
# invariant-erosion drift. Where trust catches "turn off the firewall"
# (outrageous), must catches "this file that was required is now
# missing" / "this forbidden pattern has reappeared" / "this schema
# version regressed" (subtle). Key defense against A5 (commercial
# fabrication of success "facts" — invariants ground truth against
# marketing copy) and D1 (lore fabrication about what the repo contains).

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (must.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "must",
    schema_version   = "1.0.0",
    component_type   = "contractile:must",
    semantics        = "invariant assertion — release-blocking",
    side_effects     = [],
    paired_xfile     = "../must/must.k9.ncl#declaration",
    paired_runner    = "../must/must.ncl",

    # α two-axis: Yard tier (the runner shells out for grep/test/etc.;
    # this record only declares) and read-only operations. Blocking authority because
    # must is the canonical gating verb.
    tier      = 'Yard,
    authority = 'blocking,

    metadata = {
      name = "must-k9",
      version = "1.0.0",
      description = "Evaluates release-blocking invariants as a hard gate. Third trident instance. Complements trust (ephemeral blocking) with persistent invariant blocking.",
      paired_xfile = "must.k9.ncl#declaration",
      paired_runner = "must.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      signature_required = false,
      trust_level = "read-only invariant verification with subprocess",
      allow_network = false,
      allow_filesystem_write = false,
      allow_subprocess = false,   # the paired runner spawns; this record does not
      probe_scope = 'read_only,              # must probes NEVER mutate
      probe_kinds_allowed = [
        'file_existence,
        'pattern_presence,
        'pattern_absence,
        'schema_match,
        'version_equality,
        'count_threshold,
      ],
      probe_kinds_denied = [
        'network_call,
        'filesystem_mutation,
        'external_api,
        'exploit_attempt,          # that's trust's safe_hacking territory
      ],
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Third trident instance in the estate. Completes the blocking-authority\npair (must + trust). must is concrete + persistent invariants; trust\nis concrete + ephemeral transactions. Together they gate every\nsecurity- and invariant-affecting merge.\n",
      trident_version = "1.0.0",
      semantics = "invariant assertion — release-blocking",
      cardinality = "one per repo",
      authority = "blocking (hard gate)",
      files = [
        { role = "declaration", former_path = "Mustfile.a2ml", notes = "Mustfile declaration — invariants each with id, description, probe, severity." },
        { role = "runner", former_path = "must.ncl", notes = "Runner pre-existed. Schema covers invariants array with status_core + severity." },
        { role = "k9_component", former_path = "must.k9.ncl", notes = "Hunt-restricted read-only tier; blocking authority. Tracks per-invariant trend across sessions; flags silent regressions; blocks session close on critical drift." },
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "must trident — canonical template in rsr-template-repo. Blocking-authority verb (paired with trust). Specialises in subtle invariant-erosion catchment vs trust's outrageous-attack catchment. Hard gate: any failing invariant blocks merge. Copy this trident into a new repo and replace the declaration with project-specific invariants.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "Mustfile.a2ml and must.ncl pre-existed. This manifest + must.k9.ncl complete the trident. Inherits on_open schema from intend.k9.ncl v2.0.0; inherits block_session_close_on_critical_drift + variance-severity-acknowledgement from trust.k9.ncl v1.0.0; adds must-specific track_per_session_trend + flag_silent_regression + probe_scope = 'read_only (must doesn't do active exploit attempts — that's trust's safe_hacking territory)." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into must.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the must contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of must.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Mustfile — Physical state contract for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# What MUST be true about this repository. Hard requirements.\n# Run with: must check\n# Fix with: must fix (where a deterministic fix exists)\n",
    abstract = "Physical-state invariants for rsr-template-repo. This is the canonical\nRSR template repository. These are hard requirements — CI and pre-commit\nhooks fail if any check fails.",
    prose = [
      {
        section = "Template Integrity",
        text = "# template-readonly RETIRED 2026-09-19 (standards#837 pilot): it grepped\n# RSR_TEMPLATE_DO_NOT_EDIT in .machine_readable/0.1-AI-MANIFEST.a2ml, but the\n# marker never existed outside this Mustfile and the file is now folded into\n# the repo deed — the check could only ever fail. A gate that cannot pass is\n# the fake-gate class this estate hunts; retiring it, not re-aiming it.",
      },
    ],
    invariants = [
      {
        id = "license-present",
        section = "File Presence",
        description = "LICENSE file must exist",
        probe = "test -f LICENSE",
        severity = 'critical,
      },
      {
        id = "readme-present",
        section = "File Presence",
        description = "README.adoc must exist",
        probe = "test -f README.adoc",
        severity = 'critical,
      },
      {
        id = "security-policy",
        section = "File Presence",
        description = "SECURITY.md must exist",
        probe = "test -f SECURITY.md || test -f .github/SECURITY.md",
        severity = 'critical,
      },
      {
        id = "repo-deed",
        section = "File Presence",
        description = "the repo deed (<reponame>_chora.deed) must exist at root",
        probe = "ls *_chora.deed >/dev/null 2>&1",
        severity = 'critical,
      },
      {
        id = "governance-docs",
        section = "File Presence",
        description = "governance model, maintainer roster and CODEOWNERS must exist",
        probe = "test -f docs/GOVERNANCE.adoc && test -f docs/MAINTAINERS.adoc && test -f .github/CODEOWNERS",
        severity = 'critical,
      },
      {
        id = "machine-readable-dir",
        section = "File Presence",
        description = ".machine_readable/ directory must exist",
        probe = "test -d .machine_readable",
        severity = 'critical,
      },
      {
        id = "contractiles-complete",
        section = "Directory Structure",
        description = "All required contractile directories exist",
        probe = "test -d .machine_readable/contractiles && test -d .machine_readable/contractiles/bust && test -d .machine_readable/contractiles/dust",
        severity = 'critical,
      },
      {
        id = "contractiles-files-present",
        section = "Directory Structure",
        description = "All six contractile declarations exist (<verb>/<verb>.k9.ncl)",
        probe = "for v in intend must trust adjust dust bust; do test -f .machine_readable/contractiles/$v/$v.k9.ncl || exit 1; done",
        severity = 'critical,
      },
      {
        id = "bust-dust-files-present",
        section = "Directory Structure",
        description = "The bust and dust declarations exist in their directories",
        probe = "test -f .machine_readable/contractiles/bust/bust.k9.ncl && test -f .machine_readable/contractiles/dust/dust.k9.ncl",
        severity = 'critical,
      },
      {
        id = "six-directory-present",
        section = "Directory Structure",
        description = "the repo has exactly one deed (*_chora.deed) and it carries the (anchor), (neurosym) and (playbook) clauses",
        probe = "d=$(bash scripts/deed-field.sh --find .) && bash scripts/deed-field.sh --has \"$d\" anchor && bash scripts/deed-field.sh --has \"$d\" neurosym && bash scripts/deed-field.sh --has \"$d\" playbook",
        severity = 'critical,
      },
      {
        id = "anchor-clause",
        section = "Directory Structure",
        description = "the deed carries the (anchor) clause (semantic authority + golden path)",
        probe = "bash scripts/deed-field.sh --has \"$(bash scripts/deed-field.sh --find .)\" anchor",
        severity = 'warning,
      },
      {
        id = "self-validating-structure",
        section = "Directory Structure",
        description = "self-validating directory has k9-svc and examples",
        probe = "test -d .machine_readable/self-validating && test -d .machine_readable/self-validating/k9-svc && test -d .machine_readable/self-validating/examples",
        severity = 'warning,
      },
      {
        id = "no-placeholder-values",
        section = "Template Integrity",
        description = "No placeholder values remain in template files",
        probe = "test -z \"$(grep -r '{{' .machine_readable/contractiles/ 2>/dev/null)\"",
        severity = 'critical,
        notes = "All placeholders must be substituted when copying this template",
      },
      {
        id = "no-untracked-contractiles",
        section = "Git State",
        description = "All contractile files are tracked in git",
        probe = "test -z \"$(git ls-files -o --exclude-standard .machine_readable/contractiles/ 2>/dev/null)\"",
        severity = 'critical,
      },
      {
        id = "signed-commits",
        section = "Git State",
        description = "All commits must be signed",
        probe = "git verify-commit HEAD",
        severity = 'critical,
      },
    ],
  },

  # -------------------------------------------------------------------
  # Variance schema — trust-style severity acknowledgement.
  # Because must is BLOCKING, variances carry real weight. Critical-
  # severity invariants can only be varied by maintainer-or-above.
  # -------------------------------------------------------------------
  # A record SHAPE (contract-only fields, no values): kept out of `nickel export`.
  variance_schema | not_exported = {
    entry_id     | String,   # which invariant id the variance applies to
    reason       | String,
    approved_by  | String,   # maintainer or above for critical-severity
    scope        | String,   # path glob | session-id | "until-<date>"
    expires      | String,   # absolute date; must variances cannot be open-ended
    review_notes | String | optional,
    severity_acknowledged     | [| 'critical, 'high, 'medium |],
    waived_consequence_description | String,  # plain language — what breaking the invariant actually does
  },

  execution = {
    triggers = [ 'session_close, 'on_demand, 'pre_push, 'pre_merge ],

    # Per-invariant execution. Failed invariant = blocked merge.
    per_invariant = {
      run_probe = true,
      record_outcome = true,
      respect_variance = true,    # active variance suppresses the gate
      on_unmet = 'fail,           # BLOCKING
      severity_escalation = 'honour,
      # Subtle-erosion defense: track per-invariant trend over sessions.
      # An invariant that passes once and then starts failing in a
      # later session without explicit amendment = suspect drift;
      # surface as high-priority drift log entry.
      track_per_session_trend = true,
      flag_suspicious_regressions = true,
    },

    evidence_sinks = [
      {
        kind   = 'verisimdb,
        table  = "contractile_executions",
        schema = "contractile_execution_v1",
        aux_tables = [ "must_invariant_history" ],  # per-invariant trend record
      },
      {
        kind        = 'drift_log,
        path        = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true,
      },
    ],

    # Session-close hook — re-evaluate all invariants. Block close on
    # critical drift (same policy as trust).
    on_close = {
      re_execute_all_invariants = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_new_failures = true,
      surface_expired_variances = true,
      # Critical must drift blocks session close — consistent with trust.
      block_session_close_on_critical_drift = true,
      # Must-specific: if a previously-passing invariant is now failing
      # without an associated variance or amendment, that's suspected
      # silent regression — surface prominently at next session open.
      flag_silent_regression = true,
    },

    # -----------------------------------------------------------------
    # Session-open hook — NEGOTIATION + RATIFICATION + ACCOUNTABILITY
    # (inherited from intend.k9.ncl v2.0.0 + trust.k9.ncl extensions)
    # -----------------------------------------------------------------
    on_open = {
      # --- Context presentation ---
      render_summary = 'plain_language,
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,

      # Must-specific: surface any silent regressions flagged at last
      # close so they can't quietly persist across sessions.
      include_silent_regressions = true,

      # --- Negotiation phase (five mandatory inputs) ---
      negotiation = {
        required = true,
        ai_required_inputs = [
          'timeline_realism,
          'industry_standards,      # what invariants derive from external standards
          'audience_feasibility,    # who is the invariant protecting
          'resulting_invariants,    # what NEW must entries result from the work
          'ecosystem_dependencies,  # what the invariants depend on
        ],
        user_engagement_required = true,
        user_engagement_mode = 'per_input_response,
        specification_translation = {
          ai_produces_spec_form = true,
          user_reviews_in_domain_language = true,
          schema_authoring_is_ai_responsibility = true,
          translation_faithfulness_auditable = true,
        },
      },

      # --- Accountability pledge ---
      # Must's pledge parallels trust's but around invariants rather
      # than threat model. User pledges not to disable invariants to
      # unblock merges; AI pledges to hold the line on declared
      # invariants even against enthusiastic scope expansion.
      accountability_pledge = {
        required = true,
        parties = [
          {
            role = 'user,
            pledge = "I have reviewed the declared invariants and the consequences of breaching them. I accept accountability for meeting these invariants and understand that failed invariants block merges. I will raise a variance (with severity acknowledgement) or an amendment rather than disabling a probe to unblock a merge.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will hold the declared invariants. I will refuse to weaken probes to unblock merges; I will refuse scope-creep suggestions that would remove an invariant silently; I will surface silent regressions at session close; I will require variance-with-severity or amendment for any legitimate scope shift, not quiet probe disablement.",
            signature_required = true,
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        includes_invariant_summary = true,       # must-specific
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,
      },
    },
  },

  # -------------------------------------------------------------------
  # Failure-mode defenses — must's specialisation is subtle-invariant
  # erosion. Overlaps with trust on blocking authority but focused on
  # persistent invariants rather than ephemeral transactional state.
  # -------------------------------------------------------------------
  failure_mode_defenses = [
    # Category A — enthusiasm capture
    'A1_enthusiasm_capture,          # scope breach via blocking authority
    'A5_grandiose_scale_hype,        # invariants are ground truth vs commercial hype
    # Category C — scope/capability erosion
    'C1_scope_creep,                 # feature-adjacent changes flagged if they break invariants
    'C2_capability_collapse,         # invariant removal requires amendment
    'C3_helpfulness_inflation,       # added features must respect declared invariants
    # Category D — epistemic failures
    'D1_lore_fabrication,            # invariants are verifiable truth, not AI-recollection
    'D2_completeness_illusion,       # invariant probe must cite behavioural check, not build-success
    'D3_test_theatre,                # invariants require real verification not mock-passing
    'D4_error_hiding,                # on_unmet = 'fail makes hiding impossible
    # Category E — refactor/churn
    'E1_refactor_stampede,           # refactor must preserve invariants
    'E3_premature_abstraction,       # abstraction must not violate invariants
    # Category F — session drift
    'F1_across_session_forgetting,   # track_per_session_trend catches re-introduction
  ],
}
