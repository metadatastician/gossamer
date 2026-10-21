K9!
# SPDX-License-Identifier: MPL-2.0
# adjust.k9.ncl — K9 trust-tier component of the adjust trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + adjust.ncl (runner).
#
# Verb:       adjust          (drift tolerances + corrective actions)
# Tier:       Yard            (validation with subprocess for measurement;
#                              no mutation beyond auto-fix where declared)
# Authority:  advisory        (continue-with-warnings; not blocking)
#
# adjust is the tolerance-band verb. Where must says "this MUST hold"
# and trust says "this MUST verify clean" (both binary), adjust says
# "drift ≤ X is acceptable; drift > X triggers action Y". Between them,
# adjust handles the subtle-drift territory that binary verbs can't.
#
# Cardinality: ONE adjust trident per repo.
#
# Failure-mode focus: adjust catches cumulative-small-drift patterns
# (E2 cosmetic churn accumulating into real regression, F2 context
# erosion causing gradual parameter drift). Where must flags "broken
# now", adjust flags "drifting toward broken".

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (adjust.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "adjust",
    schema_version   = "1.0.0",
    component_type   = "contractile:adjust",
    semantics        = "drift tolerances + corrective actions",
    side_effects     = [],
    paired_xfile     = "../adjust/adjust.k9.ncl#declaration",
    paired_runner    = "../adjust/adjust.ncl",

    tier      = 'Yard,
    authority = 'advisory,

    metadata = {
      name = "adjust-k9",
      version = "1.0.0",
      description = "Drift-tolerance + corrective-action runner. Fifth trident instance. First (Yard, advisory) authority pattern.",
      paired_xfile = "adjust.k9.ncl#declaration",
      paired_runner = "adjust.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      trust_level = "tolerance measurement + declared auto-fix",
      allow_network = false,
      allow_filesystem_write_conditional = true,  # auto_fix_when_available may edit
      allow_subprocess = false,   # the paired runner spawns; this record does not
      probe_scope = 'measurement_plus_declared_fix,
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Fifth trident instance. First (Yard, advisory) authority pattern —\ncomplements the (Hunt, blocking) triple (must + trust + bust) and\nthe (Hunt, reporting) north-star (intend).\n",
      trident_version = "1.0.0",
      semantics = "drift tolerances + corrective actions",
      cardinality = "one per repo",
      authority = "advisory (continue-with-warnings)",
      files = [
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "adjust trident — canonical template in rsr-template-repo. (Yard, advisory) authority pattern. Specialises in cumulative-drift catchment — tolerance bands + trend tracking + auto-fix-where-declared. Advisory (continue-with-warnings). Copy this trident into a new repo and define its drift tolerances and corrective actions.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "Adjustfile.a2ml and adjust.ncl pre-existed. This manifest + adjust.k9.ncl complete the trident. Exercises the Yard tier + advisory authority for the first time; on_exceeded = 'warn_and_attempt_fix rather than 'fail. adjust-specific track_drift_trend_over_sessions + flag_accelerating_drift." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into adjust.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the adjust contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of adjust.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Adjustfile — Drift-tolerance contract for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# Cumulative-drift catchment: tolerance bands + corrective actions.\n# Authority: advisory (Yard) — continue-with-warnings; auto_fix where deterministic.\n# Run with: adjust check\n# Fix with: adjust fix (applies deterministic patches; advisory otherwise)\n",
    abstract = "Drift tolerances and corrective actions for rsr-template-repo. Unlike\nMUST (hard gate), ADJUST tracks cumulative drift against tolerance bands\nand proposes corrective actions. Advisory — it warns and trends, it does\nnot block.",
    prose = [
    ],
    requirements = [
      {
        id = "placeholder-drift",
        section = "Template Drift",
        description = "Template placeholders should be replaced when copied",
        tolerance = "0 placeholder markers in copied repos",
        corrective = "Search and replace all {{PLACEHOLDER}} markers",
        severity = 'advisory,
        notes = "This check only applies to repos that copied from this template",
      },
      {
        id = "template-version-drift",
        section = "Template Drift",
        description = "Template version should match RSR spec version",
        tolerance = "Template version matches current RSR spec",
        corrective = "Update template to match latest RSR spec",
        severity = 'advisory,
      },
      {
        id = "readme-completeness",
        section = "Documentation Drift",
        description = "README should document all template features",
        tolerance = "README covers all contractiles and directory structure",
        corrective = "Update README.adoc with missing sections",
        severity = 'advisory,
      },
      {
        id = "example-accuracy",
        section = "Documentation Drift",
        description = "Examples in documentation should match actual template content",
        tolerance = "All code examples in docs are accurate",
        corrective = "Audit and fix examples in documentation",
        severity = 'advisory,
      },
      {
        id = "contractile-sync",
        section = "Structural Drift",
        description = "All contractiles should have matching k9 declarations and ncl implementations",
        tolerance = "Every <verb>.k9.ncl has a corresponding <verb>.ncl",
        corrective = "Write the missing <verb>.ncl from its <verb>.k9.ncl declaration",
        severity = 'advisory,
      },
      {
        id = "no-broken-symlinks",
        section = "Structural Drift",
        description = "No broken symbolic links in template structure",
        tolerance = "0 broken symlinks",
        corrective = "Run symlink-check script",
        severity = 'advisory,
      },
      {
        id = "adoc-not-md",
        section = "Accessibility Drift",
        description = "Template docs should prefer AsciiDoc",
        tolerance = "New prose docs are *.adoc",
        corrective = "Convert any new *.md to *.adoc",
        severity = 'advisory,
      },
      {
        id = "spdx-header-consistency",
        section = "Accessibility Drift",
        description = "All template files have correct SPDX headers",
        tolerance = "0 files missing SPDX-License-Identifier",
        corrective = "Add SPDX headers to files that need them",
        severity = 'advisory,
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
    # adjust-specific: which tolerance band the variance widens
    tolerance_band_widened | String,
    widened_to_value | String,
  },

  execution = {
    triggers = [ 'session_close, 'on_demand, 'pre_push ],

    per_tolerance = {
      measure_drift = true,
      record_outcome = true,
      respect_variance = true,
      # adjust-specific authority: tolerance exceeded → warn, try
      # auto-fix if declared, then continue. Never blocks.
      on_exceeded = 'warn_and_attempt_fix,
      on_auto_fix_applied = 'record_and_continue,
      on_auto_fix_unavailable = 'record_as_advisory_drift,
      # Cumulative-drift detection (adjust's specialty)
      track_drift_trend_over_sessions = true,
      flag_accelerating_drift = true,
    },

    evidence_sinks = [
      { kind = 'verisimdb, table = "contractile_executions",
        schema = "contractile_execution_v1",
        aux_tables = [ "adjust_drift_history" ] },
      { kind = 'drift_log, path = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true },
    ],

    on_close = {
      re_measure_all_tolerances = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_tolerance_exceeded = true,
      surface_expired_variances = true,
      surface_accelerating_drift = true,
      # adjust is advisory — does NOT block session close.
      block_session_close_on_any_drift = false,
    },

    on_open = {
      render_summary = 'plain_language,
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,
      include_tolerance_trend_summary = true,

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
            pledge = "I have reviewed the tolerance bands and corrective actions. I accept accountability for reviewing drift warnings rather than muting them, and for re-tuning tolerances via amendment when the intended operating envelope changes.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will surface tolerance breaches and accelerating-drift patterns at session close; I will propose corrective actions rather than widening tolerances silently; I will require amendment for legitimate tolerance re-tuning, not quiet band-widening.",
            signature_required = true,
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        includes_tolerance_bands_snapshot = true,
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,
      },
    },
  },

  failure_mode_defenses = [
    'A1_enthusiasm_capture,
    'C3_helpfulness_inflation,      # helpful additions surfaced if they widen tolerances silently
    'C4_modernization_drift,
    'E2_cosmetic_churn,             # adjust tracks cumulative churn
    'F2_context_window_erosion,     # parameter drift across sessions detected
  ],
}
