K9!
# SPDX-License-Identifier: MPL-2.0
# intend.k9.ncl — K9 trust-tier component of the intend trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + intend.ncl (runner).
# Trident completeness is a hard precondition — a repo shipping
# Intentfile without this file AND its runner is an invalid trident;
# the contractile CLI's verify gate refuses partial publication.
#
# Verb:       intend          (north star — commitments + aspirations)
# Tier:       Hunt            (capability: subprocess probes may shell out)
# Authority:  reporting       (never blocks; drift-log only)
#
# Cardinality: ONE intend trident per repo (see feedback_contractile_
# layout_rules.md). The deed's (anchor) clause is the sole multi-instance
# exception —
# it is NOT a verb contractile.
#
# Design commitments baked in (see memory trail 2026-04-18 for full
# context; key files referenced by name in annotations below):
# * α two-axis (tier × authority) — structurally separate capability
#   from authority so "Hunt tier = can override" is impossible.
# * Variance schema first-class, not comment markers
#   (feedback_audit_tool_suppression_design.md — structural > markers).
# * Sessional drift detection hooks (on_close, on_open).
# * Ratification at session open; drift log at session close.
# * Evidence sinks: VeriSimDB (queryable) + descriptiles/drift_praxis.deed (repo-local).
# * Failure-mode defenses cross-referenced to the AI failure catalog.

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (intend.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "intend",
    schema_version   = "1.0.0",
    component_type   = "contractile:intend",
    semantics        = "north-star (commitments + aspirations)",
    side_effects     = [],
    paired_xfile     = "../intend/intend.k9.ncl#declaration",
    paired_runner    = "../intend/intend.ncl",

    # α two-axis declaration — capability × authority.
    # intend is Yard-tier as a record (intend.ncl shells out for the probes)
    # and reporting-authority (never blocks). must/trust/bust declare (Yard, blocking);
    # adjust/dust will declare (Yard, advisory). Splitting the axes
    # means "I'm Hunt-tier so I can override everything" is structurally
    # impossible — authority is a separate field.
    tier      = 'Yard,
    authority = 'reporting,

    metadata = {
      name = "intend-k9",
      version = "2.0.0",             # 1.0.0 (2026-04-18 AM): initial trident.
                                     # 2.0.0 (2026-04-18 PM): negotiation +
                                     # accountability + plain-language-translation
                                     # schema baked into on_open — prerequisite for
                                     # the adversarial Gemini+Copilot drift pilot.
      description = "Executes Intentfile probes + emits drift log. Non-gating; reporting authority only. on_open hook implements negotiation-ratification-accountability protocol.",
      paired_xfile = "intend.k9.ncl#declaration",
      paired_runner = "intend.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      signature_required = false,
      trust_level = "subprocess + filesystem-read",
      allow_network = false,
      allow_filesystem_write = false,   # evidence sinks are indirected
      allow_subprocess = false,   # the paired runner spawns; this record does not
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Asserts: exactly three files constitute the intend trident; their\ncontent-hashes are pinned here; cross-references round-trip; no\npartial publication is permitted.\n\nThe contractile CLI's `verify <verb>` subcommand MUST:\n  1. Confirm all three listed files exist at the declared paths.\n  2. Compute each file's sha256 and match against the pinned value.\n  3. Follow each cross-reference and confirm the target file's\n     reciprocal field points back.\n  4. Refuse the dir (exit non-zero) if any of 1–3 fails.\n\nThis forecloses the failure mode where an agent publishes an A2ML\ndeclaration with no paired runner or K9 component — the trident is\natomically complete or it is invalid.\n",
      trident_version = "1.0.0",
      semantics = "north-star (commitments + aspirations)",
      cardinality = "one per repo",
      files = [
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "intend trident — canonical template in rsr-template-repo. North-star verb: reports progress toward committed next-actions ([[intents]]) and lists horizon aspirations ([[wishes]]). Non-gating (reporting authority). Copy this trident into a new repo and replace the declaration with project-specific content.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "intend/Intentfile.a2ml pre-existed (f380b62, lust absorption). This manifest + intend.k9.ncl complete the trident for the first time." },
        { date = "2026-04-18", event = "negotiation-accountability-schema-landed", note = "intend.k9.ncl on_open hook extended: five negotiation inputs (timeline/standards/audience/invariants/dependencies), both-parties accountability pledge, plain-language-translation policy (AI authors spec form, user reviews in domain language). K9 metadata version bumped 1.0.0 → 2.0.0. Prerequisite for the adversarial Gemini+Copilot drift pilot; intend is the hardest verb (abstract north-star) so baking the full protocol here first means simpler verbs (trust, must) can inherit the template." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into intend.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the intend contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of intend.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Intentfile — north-star contractile for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# Paired runner: intend.ncl\n# Verb:          intend\n#\n# Semantics: North-star contractile. Declares BOTH concrete committed\n#            next-actions AND horizon aspirations the project wishes to\n#            become. Two sections share one file because they answer\n#            the same question at different ranges:\n#              [[intents]] — \"we WILL do this; track progress\"\n#                            status: declared → in_progress → done |\n#                                    deferred | retired\n#              [[wishes]]  — \"we WISH this were true; revisit later\"\n#                            status: declared → in_progress → achieved |\n#                                    abandoned\n#                            grouped by horizon: near / mid / far.\n#            Non-gating — this is a report, not a gate. See the `must`\n#            contractile for hard gates.\n",
    abstract = "North-star contractile for rsr-template-repo. This repository is the\ncanonical template for Rhodium Standard Repository compliance. It provides\nthe scaffold that all hyperpolymath repos should copy and customize.",
    prose = [
      {
        section = "Purpose",
        text = "The rsr-template-repo serves as the master template for all hyperpolymath\nrepositories. It contains the complete set of contractile files, machine-readable\nspecifications, and governance documentation that define the Rhodium Standard.\n\nEvery new repository in the hyperpolymath estate should be initialized by\ncopying this template and substituting the placeholder values with\nrepo-specific content.",
      },
      {
        section = "Anti-Purpose",
        text = "This repository is NOT:\n- A general-purpose project scaffold for external use (hyperpolymath-only)\n- A replacement for per-repo customization (all files must be bespoke)\n- A static template that never changes (evolves with RSR spec)\n- A runtime library or framework (build-time only)",
      },
      {
        section = "If In Doubt",
        text = "If you are unsure whether a change is in scope, ask. Sensitive areas:\n- .machine_readable/ contractile definitions\n- RSR specification files\n- Governance templates\n- License policy documents",
      },
    ],
    intents = [
      {
        id = "repo-initialization",
        section = "Committed Next-Actions",
        description = "Provide just copy-and-substitute template for new repos",
        probe = "test -f scripts/init-repo.sh",
        status = 'done,
        notes = "Run with source scripts/init-repo.sh <new-repo-name>",
      },
      {
        id = "contractile-completeness",
        section = "Committed Next-Actions",
        description = "Every RSR contractile has a k9 declaration and an ncl implementation",
        probe = "ls .machine_readable/contractiles/*/*.k9.ncl | wc -l | grep -q \"^6$\"",
        status = 'in_progress,
        notes = "Currently 6 contractile verbs: intend, must, trust, adjust, bust, dust",
      },
      {
        id = "automation-scripts",
        section = "Committed Next-Actions",
        description = "All repetitive tasks have just recipes",
        probe = "grep -c \"^# \" Justfile | grep -q \"^[6-9][0-9]*$\"",
        status = 'in_progress,
      },
    ],
    wishes = [
      {
        id = "cross-repo-validation",
        section = "Wishes",
        group = "Near Horizon",
        description = "Tooling to validate all repos against RSR spec",
        horizon = 'near,
        status = 'declared,
      },
      {
        id = "automated-substitution",
        section = "Wishes",
        group = "Near Horizon",
        description = "Script to automate repo-specific substitution in template",
        horizon = 'near,
        status = 'declared,
      },
      {
        id = "formal-verification",
        section = "Wishes",
        group = "Mid Horizon",
        description = "Idris2 proofs for all critical contractile invariants",
        horizon = 'mid,
        status = 'declared,
      },
      {
        id = "ecosystem-visualization",
        section = "Wishes",
        group = "Far Horizon",
        description = "Interactive graph of all hyperpolymath repos and dependencies",
        horizon = 'far,
        status = 'declared,
      },
    ],
  },

  # -------------------------------------------------------------------
  # Variance schema — P-shape scoped exceptions per entry.
  # A variance suppresses a specific intent's or wish's obligation for a
  # reason, with approver + expiry. Expired variance = effective
  # re-imposition of the obligation. Unmet intent without a variance =
  # drift, logged to the drift log.
  # Per user 2026-04-18: variances are structural, not magic-comment
  # markers — markers are gameable.
  # -------------------------------------------------------------------
  # A record SHAPE (contract-only fields, no values): kept out of `nickel export`.
  variance_schema | not_exported = {
    entry_id     | String,   # which intent/wish id the variance applies to
    reason       | String,
    approved_by  | String,
    scope        | String,   # path glob | session-id | "until-<date>"
    expires      | String,   # absolute date or condition
    review_notes | String | optional,
  },

  # -------------------------------------------------------------------
  # Execution policy
  # -------------------------------------------------------------------
  execution = {
    # When the component runs.
    # session_close is mandatory (the "picked up sessionally" check).
    triggers = [ 'session_close, 'on_demand, 'pre_push ],

    # Per-intent execution.
    per_intent = {
      run_probe = true,
      record_outcome = true,
      respect_variance = true,    # active variance suppresses failure
      on_unmet = 'log_drift,      # never 'fail — authority = reporting
    },

    # Per-wish execution (wishes are non-probeable; horizon-group only).
    per_wish = {
      run_probe = false,
      emit_horizon_summary = true,
      # Vertical alignment soft-check per user_descriptiles_is_contractile_ought.md:
      # highest-level alignment is meta ↔ north-star (soft), not hard gate.
      check_alignment_with_META = true,
    },

    # Evidence sinks — BOTH written, every execution.
    # VeriSimDB = queryable machine record (feedback_verisimdb_policy.md).
    # descriptiles/drift_praxis.deed = repo-local append-only drift log (feedback_sessional_
    # drift_detection.md + user_descriptiles_is_contractile_ought.md descriptive role).
    evidence_sinks = [
      {
        kind   = 'verisimdb,
        table  = "contractile_executions",
        schema = "contractile_execution_v1",
      },
      {
        kind        = 'drift_log,
        path        = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true,
      },
    ],

    # Session-close hook — the "picked up sessionally" requirement.
    # Re-execute, diff against the last ratification, surface expired
    # variances, emit drift entries for new failures.
    on_close = {
      re_execute_all_intents = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_new_failures = true,
      surface_expired_variances = true,
    },

    # -----------------------------------------------------------------
    # Session-open hook — NEGOTIATION + RATIFICATION + ACCOUNTABILITY
    # (user_contract_negotiation_and_accountability_pledge.md)
    # (user_contractiles_agreed_at_session_start.md)
    #
    # Ratification is not passive acknowledgement; it is negotiation
    # ending in an explicit accountability pledge from BOTH parties.
    # Work cannot proceed before both pledges are on file.
    # -----------------------------------------------------------------
    on_open = {
      # --- Context presentation (pre-negotiation) ---
      render_summary = 'plain_language,    # metaphor-capture defense
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,

      # --- Negotiation phase (five mandatory inputs) ---
      # AI must surface all five before the user is asked to ratify.
      # "Yes, and …" — not "yes". Missing any of the five = the
      # negotiation is incomplete and work cannot proceed.
      negotiation = {
        required = true,              # blank-cheque ratification refused

        # The five inputs the AI must contribute to the negotiation.
        # Each is a structured field the agent is required to populate,
        # not optional prose. See user_contract_negotiation_and_
        # accountability_pledge.md for the domain-language-rendering rule.
        ai_required_inputs = [
          'timeline_realism,           # "this will take X; not Y"
          'industry_standards,         # WCAG, ISO, OWASP, GDPR, licensing …
          'audience_feasibility,       # real addressable user set
          'resulting_invariants,       # what must/trust/adjust entries follow
          'ecosystem_dependencies,     # libs, licences, threat-model implications
        ],

        # User must actually engage with each input — not
        # auto-approve. If user tries to skip ("just do it, I trust you")
        # the system re-renders the obligations and requires the pledge.
        user_engagement_required = true,
        user_engagement_mode = 'per_input_response,

        # The AI does the specification-form work. The user reviews the
        # rendering in domain language and accepts / amends / pushes back.
        # User never has to author Nickel schemas or decide on type
        # specificity — that is the AI's translation responsibility,
        # with auditable faithfulness.
        specification_translation = {
          ai_produces_spec_form = true,
          user_reviews_in_domain_language = true,
          schema_authoring_is_ai_responsibility = true,
          translation_faithfulness_auditable = true,
          # Failure mode this closes: user is forced to learn spec-theory
          # (type refinement, Nickel contract grammar) to ratify a contract
          # — which drives users away from ratification entirely.
        },
      },

      # --- Accountability pledge (both parties, explicit) ---
      # Not "I read it" — "I am answerable for this obligation".
      # Both pledges are required before work proceeds; both are recorded.
      accountability_pledge = {
        required = true,
        parties = [
          {
            role = 'user,
            pledge = "I have reviewed the obligations as negotiated; I accept accountability for meeting the declared invariants and for the audience/timeline/standards consequences surfaced in negotiation.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will hold the user to the obligations as negotiated, including by surfacing drift at session close and refusing off-contract actions, even when the user is enthusiastic about them. If the user wishes to depart from the contract, I will require a variance or amendment, not silent acceptance.",
            signature_required = true,
            # Per user_contractile_is_contract_do_not_break.md —
            # the AI is the holder of the line against enthusiasm drift.
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      # --- Policy: ratification output ---
      # The ratification record IS the negotiation transcript + the
      # accountability pledge combined. One document; future-session
      # ground-truth for "what was agreed, who is accountable".
      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,    # pins what was actually signed
      },
    },
  },

  # -------------------------------------------------------------------
  # Failure-mode defenses — explicit cross-reference to the catalog
  # (feedback_ai_failure_mode_catalog.md). New catalog entries that
  # shift this verb's defenses must update this list, not narrative.
  # -------------------------------------------------------------------
  failure_mode_defenses = [
    'A1_enthusiasm_capture,            # scope breach → drift log
    'A2_metaphor_capture,              # render_summary = 'plain_language
    'A3_allegory_drift,                # intents cite concrete obligations
    'C1_scope_creep,                   # feature-adjacent change needs intent_id
    'C3_helpfulness_inflation,         # changes without intent_id flagged
    'C4_modernization_drift,           # upgrade cannot cite intent → drift
    'D5_sycophancy,                    # ratification compares user framing vs contract
    'F1_across_session_forgetting,     # on_open reads last-ratification record
  ],
}
