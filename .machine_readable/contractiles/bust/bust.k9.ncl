K9!
# SPDX-License-Identifier: MPL-2.0
# bust.k9.ncl — K9 trust-tier component of the bust trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + bust.ncl (runner).
#
# Verb:       bust            (hard-stop / expiry / "must-not-run")
# Tier:       Hunt-read-only  (subprocess probes for expiry/state checks)
# Authority:  blocking        (HARD GATE on declared broken states)
#
# bust is the "this is broken, this has expired, this must not run"
# declarative surface. Where must asserts invariants that must hold,
# bust asserts failure states that must not be re-entered. Complement
# to must: together they bound the "acceptable operating state" from
# above (must) and below (bust).
#
# Cardinality: ONE bust trident per repo.
#
# Failure-mode focus: bust catches deprecated-path-still-called
# patterns (C2 capability collapse attempts where an AI reintroduces
# retired code), expiry-exceeded state (certificates / tokens / grants
# past their expiry), and the "it works, ship it" pattern where a
# caller silently starts using a must-not-run API.

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (bust.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "bust",
    schema_version   = "1.0.0",
    component_type   = "contractile:bust",
    semantics        = "hard-stop / expiry / must-not-run declarations",
    side_effects     = [],
    paired_xfile     = "../bust/bust.k9.ncl#declaration",
    paired_runner    = "../bust/bust.ncl",

    tier      = 'Yard,
    authority = 'blocking,

    metadata = {
      name = "bust-k9",
      version = "1.0.0",
      description = "Hard-stop / expiry / must-not-run gate. Fourth trident instance. Completes the blocking-authority triple (must + trust + bust).",
      paired_xfile = "bust.k9.ncl#declaration",
      paired_runner = "bust.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      signature_required = false,
      trust_level = "read-only expiry + state-check with subprocess",
      allow_network = false,
      allow_filesystem_write = false,
      allow_subprocess = false,   # the paired runner spawns; this record does not
      probe_scope = 'read_only,
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Fourth trident instance. Completes the blocking-authority triple:\nmust (persistent invariants), trust (ephemeral transactions),\nbust (hard-stop / expiry / must-not-run). Between them, every\nrelease-blocking contractile concern is covered.\n",
      trident_version = "1.0.0",
      semantics = "hard-stop / expiry / must-not-run declarations",
      cardinality = "one per repo",
      authority = "blocking (hard gate)",
      files = [
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "bust trident — canonical template in rsr-template-repo. Completes the blocking-authority triple (must + trust + bust). Specialises in deprecated-path-reintroduction catchment. Declares hard-stop / expiry / must-not-run conditions. Copy this trident into a new repo and declare its real breakage / expiry conditions.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "Bustfile.a2ml and bust.ncl pre-existed. This manifest + bust.k9.ncl complete the trident. Inherits the full negotiation+accountability schema from intend.k9.ncl v2.0.0 + trust/must extensions; adds flag_deprecated_reintroduction for C2-defense specificity." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into bust.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the bust contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of bust.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Bustfile — failure mode contractile for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# Paired runner: bust.ncl\n# Verb:          bust\n# Semantics:     Every declared failure mode must have a working recovery path\n#                that has been exercised. Status moves:\n#                  declared → drilled (probe run) → verified (recovery confirmed)\n#                  or → failing (recovery broken)\n#\n# CLI:\n#   contractile bust check  → list failure modes + recovery status\n#   contractile bust drill  → inject failures, verify recovery paths\n#\n# This repository: rsr-template-repo is the canonical template for RSR compliance.\n# Failure modes here relate to template distribution and substitution.\n",
    abstract = "Bustfile for rsr-template-repo. Lists failure modes specific to the template\nrepository itself, particularly around template distribution, substitution,\nand synchronization across the hyperpolymath estate.",
    prose = [
    ],
    failure_modes = [
      {
        id = "template-substitution-failure",
        section = "Failure Modes",
        class = 'template_processing,
        description = "Template substitution fails when initializing a new repo from this template",
        injection_probe = "cp -r rsr-template-repo test-repo && cd test-repo && sed -i 's/rsr-template-repo/TEST/g' .machine_readable/contractiles/intend/intend.k9.ncl && grep -q 'TEST' .machine_readable/contractiles/intend/intend.k9.ncl",
        recovery_probe = "git -C test-repo diff --quiet .machine_readable/contractiles/intend/intend.k9.ncl",
        expected_recovery_time_seconds = 10,
        status = 'declared,
        notes = "Verify that substitution scripts handle all placeholder replacements correctly",
      },
      {
        id = "sync-drift-between-repos",
        section = "Failure Modes",
        class = 'synchronization,
        description = "Drift occurs between rsr-template-repo and other repos after template updates",
        injection_probe = "echo 'template_updated' > /tmp/test_drift_marker",
        recovery_probe = "test -f /tmp/test_drift_marker && rm /tmp/test_drift_marker",
        expected_recovery_time_seconds = 60,
        status = 'declared,
        notes = "The estate-wide sync scripts (see scripts/) should prevent this; verify with scripts/verify-sync.sh",
      },
      {
        id = "contractile-parse-error",
        section = "Failure Modes",
        class = 'contractile_format,
        description = "A contractile file fails to parse due to syntax errors",
        injection_probe = "echo 'invalid syntax' >> rsr-template-repo/.machine_readable/contractiles/intend/intend.k9.ncl",
        recovery_probe = "git checkout rsr-template-repo/.machine_readable/contractiles/intend/intend.k9.ncl",
        expected_recovery_time_seconds = 5,
        status = 'declared,
        notes = "Every <verb>.k9.ncl must typecheck; validate with .github/hooks/validate-k9.sh and nickel typecheck",
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
    severity_acknowledged | [| 'critical, 'high, 'medium |],
    waived_consequence_description | String,
  },

  execution = {
    triggers = [ 'session_close, 'on_demand, 'pre_push, 'pre_merge ],

    per_hard_stop = {
      run_probe = true,
      record_outcome = true,
      respect_variance = true,
      on_triggered = 'fail,        # BLOCKING — bust condition hit = block
      severity_escalation = 'honour,
      # bust-specific: detect re-introduction of deprecated calls
      flag_deprecated_reintroduction = true,
    },

    evidence_sinks = [
      { kind = 'verisimdb, table = "contractile_executions",
        schema = "contractile_execution_v1",
        aux_tables = [ "bust_triggers_history" ] },
      { kind = 'drift_log, path = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true },
    ],

    on_close = {
      re_execute_all_hard_stops = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_new_triggers = true,
      surface_expired_variances = true,
      block_session_close_on_critical_bust = true,
    },

    on_open = {
      render_summary = 'plain_language,
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,
      include_silent_regressions = true,

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
            pledge = "I have reviewed the declared hard-stop / expiry / must-not-run conditions. I accept accountability for not calling into must-not-run code paths, not ignoring expired tokens/grants, and not silently reintroducing deprecated patterns. I will raise a variance with severity acknowledgement if an exception is needed.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will refuse suggestions that reintroduce must-not-run patterns; I will surface bust triggers at session close; I will require variance-with-severity for any legitimate reintroduction of a deprecated path rather than silently allowing it.",
            signature_required = true,
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,
      },
    },
  },

  failure_mode_defenses = [
    'A1_enthusiasm_capture,
    'C2_capability_collapse,       # prevents reintroduction of retired capability
    'C4_modernization_drift,       # bust prevents silent re-adoption of deprecated libs
    'D4_error_hiding,
    'E1_refactor_stampede,         # refactor that reintroduces deprecated path caught
    'F1_across_session_forgetting, # bust triggers persist across sessions
  ],
}
