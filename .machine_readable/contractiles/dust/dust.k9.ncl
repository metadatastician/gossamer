K9!
# SPDX-License-Identifier: MPL-2.0
# dust.k9.ncl — K9 trust-tier component of the dust trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + dust.ncl (runner).
#
# Verb:       dust            (rollback / recovery / deprecation)
# Tier:       Yard            (audit + structural checks; destructive
#                              actions gated behind --apply flag +
#                              explicit per-item approval)
# Authority:  advisory        (continue-with-warnings)
#
# dust is the retirement + audit-trail verb. Rollback paths, deprecation
# markers, evidence-preservation semantics. Where bust declares
# "broken, don't run", dust declares "how to safely undo / retire / roll
# back". Complement to bust — bust marks the dead end, dust describes
# the exit ramp.
#
# Cardinality: ONE dust trident per repo.
#
# Failure-mode focus: dust is the audit-trail preservation verb —
# defends against E1 refactor stampede (check audit trail still
# intact) and against silent removal (anything removed must have a
# rollback path; anything retired must preserve the evidence of its
# previous existence).

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (dust.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "dust",
    schema_version   = "1.0.0",
    component_type   = "contractile:dust",
    semantics        = "rollback / recovery / deprecation / audit-trail preservation",
    side_effects     = [],
    paired_xfile     = "../dust/dust.k9.ncl#declaration",
    paired_runner    = "../dust/dust.ncl",

    tier      = 'Yard,
    authority = 'advisory,

    metadata = {
      name = "dust-k9",
      version = "1.0.0",
      description = "Rollback + deprecation + audit-trail runner. Sixth trident instance — completes the full verb set.",
      paired_xfile = "dust.k9.ncl#declaration",
      paired_runner = "dust.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      trust_level = "audit-trail verification + structural checks",
      allow_network = false,
      # dust is the verb that ACTUALLY wants filesystem write — to
      # execute declared rollback/removal — but only behind explicit
      # --apply flag + per-item approval. Default is dry-run.
      allow_filesystem_write_conditional = true,
      allow_subprocess = false,   # the paired runner spawns; this record does not
      destructive_action_gating = {
        default_mode = 'dry_run,
        requires_flag = "--apply",
        requires_per_item_approval = true,
        approval_mechanism = 'explicit_user_signature,
      },
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Sixth + final trident instance. Completes the full verb set —\nthe estate now has tridents for every contractile verb.\n",
      trident_version = "1.0.0",
      semantics = "rollback / recovery / deprecation / audit-trail preservation",
      cardinality = "one per repo",
      authority = "advisory (continue-with-warnings)",
      files = [
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "dust trident — canonical template in rsr-template-repo. Specialises in audit-trail preservation + rollback-path verification. Yard tier with destructive-action gating (dry-run default; --apply + per-item approval required for mutations). Copy this trident into a new repo and describe how it actually rolls back or retires behaviour.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "Dustfile.a2ml and dust.ncl pre-existed. This manifest + dust.k9.ncl complete the trident and the full verb set. All 6 verbs now on trident shape: intend (Hunt, reporting), trust (Hunt, blocking), must (Hunt-read-only, blocking), bust (Hunt-read-only, blocking), adjust (Yard, advisory), dust (Yard, advisory)." },
        { date = "2026-04-18", event = "verb-set-complete", note = "Full estate trident coverage. Blocking-authority triple (must/trust/bust) handles release-gating. Advisory pair (adjust/dust) handles drift-warning and audit-trail. Single reporting verb (intend) handles north-star. α two-axis surface fully exercised on all four (tier, authority) combinations used: (Hunt, reporting), (Hunt, blocking), (Hunt-read-only, blocking), (Yard, advisory). The contractile system is ready for the adversarial Gemini+Copilot drift pilot." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into dust.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the dust contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of dust.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Dustfile — Cleanup and hygiene contract for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# Paired runner: dust.ncl\n# Verb:          dust\n# Semantics:     What should be cleaned up. Housekeeping, not blockers.\n#\n# This repository: rsr-template-repo is the canonical template.\n# Cleanup items here ensure the template itself remains pristine.\n",
    abstract = "Cleanup and hygiene items for rsr-template-repo. These are maintenance tasks\nthat ensure the template repository remains clean and ready for distribution\nto new repositories.",
    prose = [
    ],
    removal_candidates = [
      {
        id = "no-template-artifacts",
        section = "Stale Files",
        description = "No generated files from template testing in root",
        probe = "test -z \"$(ls template-test-* 2>/dev/null)\"",
        severity = 'info,
        notes = "Template testing should use /tmp or dedicated test directories",
      },
      {
        id = "no-example-placeholders",
        section = "Stale Files",
        description = "No example placeholder files (EXAMPLE-, SAMPLE-) in contractiles/",
        probe = "test -z \"$(find .machine_readable/contractiles/ -name 'EXAMPLE-*' -o -name 'SAMPLE-*' 2>/dev/null)\"",
        severity = 'warning,
        notes = "All placeholders should be replaced with actual content or removed",
      },
      {
        id = "no-old-contractile-formats",
        section = "Stale Files",
        description = "No old .contractile, .hs or retired .a2ml files remaining",
        probe = "test -z \"$(find .machine_readable/contractiles/ \\( -name '*.contractile' -o -name '*.hs' -o -name '*.a2ml' \\) 2>/dev/null)\"",
        severity = 'warning,
        notes = "All contractiles are <verb>/<verb>.k9.ncl declarations plus <verb>.ncl implementations",
      },
      {
        id = "justfile-imports-in-sync",
        section = "Format Duplicates",
        description = "The root Justfile and its contractiles mirror declare the SAME import? set",
        probe = "diff <(grep '^import?' Justfile) <(grep '^import?' .machine_readable/contractiles/Justfile) >/dev/null",
        severity = 'warning,
        notes = "Replaces a no-duplicate-justfile rule that compared INODES to assert the two\nfiles were hardlinked. That rule could never pass: git does not track\nhardlinks, so the pair have separate inodes after any clone (measured:\n1026120 vs 1031824). Its premise was also false — these are not one file\nseen twice but two deliberately different Justfiles, differing by 88 lines,\nso swapping the inode test for `cmp` would merely exchange one\nalways-failing check for another. `stat -c` is GNU-only too, so it broke on\nmacOS regardless.\n\nWhat actually must hold is that the mirror declares the same import? set as\nthe root — that is the drift which silently breaks recipes, because `import?`\nis the OPTIONAL form and fails quietly rather than erroring. Both currently\ndeclare 7 imports and agree.\n",
      },
      {
        id = "no-duplicate-readme-format",
        section = "Format Duplicates",
        description = "Only one README format in contractiles/ (.adoc canonical)",
        probe = "test ! -f .machine_readable/contractiles/README.md",
        severity = 'info,
      },
      {
        id = "no-stale-template-references",
        section = "Template Hygiene",
        description = "No references to rsr-template-repo in generic template files",
        probe = "test -z \"$(grep -r 'rsr-template-repo' machine-readable-design/ 2>/dev/null)\"",
        severity = 'warning,
        notes = "Generic templates should use gossamer or similar placeholders",
      },
      {
        id = "version-sync-checked",
        section = "Template Hygiene",
        description = "Version in canonical-directory-structure matches .machine_readable/contractiles",
        verification = "compare version identifiers in both locations",
        severity = 'info,
      },
    ],
  },

  # A record SHAPE (contract-only fields, no values): kept out of `nickel export`.
  variance_schema | not_exported = {
    entry_id     | String,
    reason       | String,
    approved_by  | String,
    scope        | String,
    expires      | String,
    review_notes | String | optional,
    rollback_path_preserved | Bool,    # dust-specific: did the variance preserve rollback?
  },

  execution = {
    triggers = [ 'session_close, 'on_demand ],

    per_retirement = {
      verify_rollback_path_documented = true,
      verify_audit_trail_preserved = true,
      respect_variance = true,
      on_rollback_path_missing = 'warn,          # advisory, not block
      on_audit_trail_broken = 'warn,             # advisory, not block
      # dust-specific: flag any retirement that has been requested but
      # lacks proper rollback documentation
      flag_unsafe_retirement = true,
    },

    evidence_sinks = [
      { kind = 'verisimdb, table = "contractile_executions",
        schema = "contractile_execution_v1",
        aux_tables = [ "dust_retirement_history" ] },
      { kind = 'drift_log, path = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true },
    ],

    on_close = {
      re_verify_all_retirement_paths = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_missing_rollback = true,
      emit_drift_entries_for_broken_audit_trail = true,
      surface_expired_variances = true,
      block_session_close_on_any_drift = false,   # advisory
    },

    on_open = {
      render_summary = 'plain_language,
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,

      negotiation = {
        required = true,
        ai_required_inputs = [
          'timeline_realism,
          'industry_standards,
          'audience_feasibility,
          'resulting_invariants,
          'ecosystem_dependencies,
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

      accountability_pledge = {
        required = true,
        parties = [
          {
            role = 'user,
            pledge = "I have reviewed the declared rollback paths and deprecation markers. I accept accountability for preserving audit trails when retiring code, and for ensuring every retired capability has a documented rollback path. I will not silently delete evidence of prior state.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will verify audit-trail preservation in any retirement / rollback / deprecation I perform; I will refuse silent deletion of prior-state evidence; I will require rollback-path documentation before accepting a retirement request; I will operate in dry-run mode by default and require explicit --apply + per-item approval for destructive actions.",
            signature_required = true,
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        includes_retirement_schedule = true,
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,
      },
    },
  },

  failure_mode_defenses = [
    'A1_enthusiasm_capture,
    'C2_capability_collapse,        # retirement without rollback path = capability collapse
    'D5_sycophancy,                 # AI won't agree to silent deletion
    'E1_refactor_stampede,          # audit trail preservation check
    'E2_cosmetic_churn,
    'F1_across_session_forgetting,  # retirement history tracked cross-session
  ],
}
