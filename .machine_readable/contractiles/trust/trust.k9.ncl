K9!
# SPDX-License-Identifier: MPL-2.0
# trust.k9.ncl — K9 trust-tier component of the trust trident
# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Pairs with: the `declaration` field of this file + trust.ncl (runner).
# Trident completeness is a hard precondition — a repo shipping
# Trustfile without this file AND its runner is an invalid trident;
# the contractile CLI's verify gate refuses partial publication.
#
# Verb:       trust           (security + provenance + safe-hacking)
# Tier:       Hunt            (capability: subprocess probes may shell out,
#                              active probes in safe_hacking section)
# Authority:  blocking        (HARD GATE — opposite of intend's reporting)
#
# trust is the concrete + ephemeral + transactional verb per user
# 2026-04-18: port use, BLAKE3 hashing, auth challenges, TLS state,
# session tokens. Every probe has instant binary ground truth.
# This is the α two-axis complement to intend: both Hunt-tier, opposite
# authority poles. Validating the architecture on both exercises the
# full (tier, authority) surface.
#
# Cardinality: ONE trust trident per repo (see feedback_contractile_
# layout_rules.md). The deed's (anchor) clause is the sole multi-instance
# exception —
# it is NOT a verb contractile.
#
# Design commitments baked in (full memory trail under
# ~/.claude/projects/-var-mnt-eclipse-repos/memory/ 2026-04-18):
# * α two-axis (Hunt, blocking) — trust is where the contractile system
#   grows teeth. Failed verification = failed CI = blocked merge.
# * Variance schema first-class — scoped exceptions structural, not
#   comment markers.
# * Sessional drift detection hooks — re-verify every close.
# * Ratification negotiation with threat-model foregrounded
#   (feedback_ai_failure_mode_catalog.md B1 — threat-model
#   misclassification is the PRIMARY defense trust provides).
# * Accountability pledge — both parties sign before security-affecting
#   work proceeds.
# * Plain-language translation — user never authors a Nickel schema for
#   a cipher suite; AI does the spec work, user reviews in domain
#   language ("TLS 1.3 with PQ key exchange, HSTS preload, 1yr").
# * Evidence sinks: VeriSimDB (queryable) + descriptiles/drift_praxis.deed (repo-local).
# * Failure-mode defenses cross-referenced — trust carries the most
#   defenses of any verb because the threat surface is widest.

#
# 2026-10-19 (K9 contract v1.0.0, D173, standards#1058): this record is a
# DECLARATION evaluated at 'Yard. The probes it lists are run by the paired
# runner (trust.ncl and the scripts/run-*.sh runners), which is the execution
# surface; this file spawns nothing. A 'Hunt record needs signature_required,
# a signature block and a verified signature (K9-S008/S009/C001); no
# contractile carries one, so 'Hunt here was a claim the gate could never honour.

let base    = import "../_base.ncl" in

{
  pedigree = base.pedigree_schema & {
    contractile_verb = "trust",
    schema_version   = "1.0.0",
    component_type   = "contractile:trust",
    semantics        = "security + provenance + safe-hacking",
    side_effects     = [],
    paired_xfile     = "../trust/trust.k9.ncl#declaration",
    paired_runner    = "../trust/trust.ncl",

    # α two-axis declaration — capability × authority.
    # trust is Yard-tier as a record (the runner, trust.ncl, shells out for the
    # active probes and the safe-hacking attempts scoped to the repo)
    # AND blocking-authority (failed verification = failed CI).
    # Contrast with intend = (Hunt, reporting). The two verbs exercise
    # the full α surface.
    tier      = 'Yard,
    authority = 'blocking,

    metadata = {
      name = "trust-k9",
      version = "1.0.0",
      description = "Executes security verifications + authorised safe-hacking probes. HARD GATE: failed verification blocks merge. Catches the 'turn off the firewall' class of drift directly. Implements negotiation-ratification-accountability protocol inherited from intend.k9.ncl v2.0.0.",
      paired_xfile = "trust.k9.ncl#declaration",
      paired_runner = "trust.ncl",
      author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
    },

    security = {
      leash = 'Yard,
      signature_required = false,
      trust_level = "verification + authorised-probe + hard-gate",
      allow_network = false,            # verifications offline by default
      allow_filesystem_write = false,   # evidence sinks are indirected
      allow_subprocess = false,   # the paired runner spawns; this record does not
      authorised_probes_only = true,    # probe section explicitly lists allowed targets + probe classes
      probe_scope_enforcement = 'this_repo_only,  # probes NEVER hit external systems
    },

    # Trident manifest — folded in from the retired <verb>.manifest.a2ml.
    # The sha256 / size_bytes fields were "pending-first-verify" placeholders
    # and the cross_refs named the retired Xfile; both are dropped. The
    # declaration now lives in this file (`declaration` below), so the
    # trident is runner + this k9 component.
    trident = {
      notes = "Asserts: exactly three files constitute the trust trident; their\ncontent-hashes are pinned here; cross-references round-trip; no\npartial publication is permitted.\n\nThe contractile CLI's `verify trust` subcommand MUST:\n  1. Confirm all three listed files exist at the declared paths.\n  2. Compute each file's sha256 and match against the pinned value.\n  3. Follow each cross-reference and confirm the target file's\n     reciprocal field points back.\n  4. Refuse the dir (exit non-zero) if any of 1–3 fails.\n\ntrust is the concrete + ephemeral + transactional verb (per user\n2026-04-18); first blocking-authority trident in the estate. Exercises\nthe (Hunt, blocking) authority pattern — complement to intend's\n(Hunt, reporting). Primary defense against failure mode B1 (threat-\nmodel misclassification) and the \"turn off the firewall\" class of\ndrift attempts the adversarial pilot is designed to exercise.\n",
      trident_version = "1.0.0",
      semantics = "security + provenance + safe-hacking",
      cardinality = "one per repo",
      authority = "blocking (hard gate)",
      files = [
        { role = "declaration", former_path = "Trustfile.a2ml", notes = "Extensively populated exemplar; covers threat model, DNS, TLS, crypto, SDP, safe-hacking, response headers, container supply chain, Cloudflare edge." },
        { role = "runner", former_path = "trust.ncl", notes = "Runner existed pre-trident; schema covers verifications + safe_hacking with authorised-probes-only, this_repo_only scope enforcement." },
        { role = "k9_component", former_path = "trust.k9.ncl", notes = "Trust-tier Hunt with blocking authority. on_open foregrounds threat model before negotiation; block_session_close_on_critical_drift." },
      ],
      signed_by = {
        user = "Jonathan D.A. Jewell",
        date = "2026-04-18",
        context = "trust trident — canonical template in rsr-template-repo. (Hunt, blocking) authority pattern. Primary catchment for adversarial drift test scenarios (firewall-off, cleartext-auth, PQ-downgrade, CSP-weaken). Hard gate: failed verification blocks merge. Copy this trident into a new repo and point it at the real keys, policies, and authority boundaries.",
      },
      history = [
        { date = "2026-04-18", event = "trident-born", note = "Trustfile.a2ml and trust.ncl pre-existed. This manifest + trust.k9.ncl complete the trident. Inherits on_open negotiation + accountability + plain-language-translation schema from intend.k9.ncl v2.0.0; adds trust-specific threat_model_foregrounding + block_session_close_on_critical_drift + stricter accountability pledge (user cannot disable verification to unblock merges)." },
        { date = "2026-10-06", event = "a2ml-retired", note = "The A2ML declaration and this manifest were folded into trust.k9.ncl (declaration + pedigree.trident) under the owner directive that no .a2ml file remains. Item ids, probes and prose were carried over unchanged." },
      ],
    },
  },

  # -------------------------------------------------------------------
  # Declaration — the trust contract data. Migrated losslessly from the
  # retired A2ML Xfile (owner directive: zero A2ML files). Item records
  # carry the field names of trust.ncl's `schema`; values are kept exactly
  # as authored, so the runner schema is NOT applied as a contract here
  # (several authored severities / classes / fields fall outside its enums).
  # Read by .machine_readable/coaptation/extract-clauses.sh.
  # -------------------------------------------------------------------
  declaration = {
    preamble = "# SPDX-License-Identifier: MPL-2.0\n# Trustfile — Trust boundaries and integrity invariants for rsr-template-repo\n# Author: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>\n#\n# Defines what LLM/SLM agents are trusted to do without asking, and\n# integrity invariants that verify the repo has not been tampered with.\n",
    abstract = "Trust boundaries and integrity checks for rsr-template-repo. This file\ncombines the trust-level definitions from the original TRUST.contractile\nwith the integrity invariants from the old Trustfile.a2ml. It defines\nwhat AI agents may do autonomously and what requires human approval,\nplus checks that verify repository integrity.",
    prose = [
      {
        section = "Trust Levels",
        text = "The rsr-template-repo operates at trust level: maximal\n\nTrust levels:\n- maximal:    Agent may read, build, test, lint, format, heal freely.\n             Only destructive/external actions require approval.\n- standard:   Agent may read and build. Test/lint need approval.\n- restricted: Agent may read only. All modifications need approval.\n- minimal:    Agent may read specific files only. Everything else blocked.\n\nCurrent trust level: maximal",
      },
    ],
    verifications = [
      {
        id = "no-secrets-committed",
        section = "Integrity Invariants",
        group = "Secrets",
        description = "No credential files in repo",
        probe = "test ! -f .env && test ! -f credentials.json && test ! -f .env.local && test ! -f .env.production",
        severity = 'critical,
      },
      {
        id = "no-private-keys",
        section = "Integrity Invariants",
        group = "Secrets",
        description = "No private key files committed",
        probe = "! find . -name '*.pem' -o -name '*.key' -o -name 'id_rsa' -o -name 'id_ed25519' 2>/dev/null | grep -v node_modules | head -1 | grep -q .",
        severity = 'critical,
      },
      {
        id = "no-tokens-in-source",
        section = "Integrity Invariants",
        group = "Secrets",
        description = "No hardcoded API tokens in source",
        probe = "! grep -rE '(api[_-]?key|secret|token|password)\\s*[:=]\\s*[\"'\\''][A-Za-z0-9]{16,}' --include='*.js' --include='*.ts' --include='*.res' --include='*.py' . 2>/dev/null | grep -v node_modules | head -1 | grep -q .",
        severity = 'critical,
      },
      {
        id = "author-correct",
        section = "Provenance",
        description = "Git author matches expected identity",
        probe = "git log -1 --format='%ae' | grep -qE '(hyperpolymath|j\\.d\\.a\\.jewell)'",
        severity = 'warning,
      },
      {
        id = "license-content",
        section = "Provenance",
        description = "LICENSE is the canonical MPL-2.0 text",
        probe = "grep -q 'Mozilla Public License Version 2.0' LICENSE",
        severity = 'warning,
      },
      {
        id = "template-files-readonly",
        section = "Template-Specific Trust",
        description = "Template scaffold files should not be modified except by maintainer",
        probe = "test -z \"$(git status --short .machine_readable/ 2>/dev/null | grep -v '^??' || true)\"",
        severity = 'advisory,
        notes = "Changes to template files require careful review",
      },
      {
        id = "trust-deny-areas",
        section = "Template-Specific Trust",
        description = "Sensitive areas from INTENT.contractile require explicit approval",
        probe = "echo \"Check .machine_readable/ contractiles and governance docs\"",
        severity = 'advisory,
        areas = [".machine_readable/", "docs/GOVERNANCE.adoc", "docs/MAINTAINERS.adoc", ".github/CODEOWNERS"],
      },
      {
        id = "container-images-pinned",
        section = "Container Security",
        description = "Containerfile uses pinned base images",
        probe = "test ! -f Containerfile || grep -q 'cgr.dev\\|@sha256:' Containerfile",
        severity = 'warning,
      },
      {
        id = "no-dockerfile",
        section = "Container Security",
        description = "No Dockerfile (use Containerfile)",
        probe = "test ! -f Dockerfile",
        severity = 'warning,
      },
      {
        id = "site-security-headers",
        section = "Website Security",
        description = "Any website directory (www, site, docs/site) must contain a security_headers directory",
        probe = "for d in www site docs/site; do if [ -d \"$d\" ]; then test -d \"$d/security_headers\" || exit 1; fi; done",
        severity = 'critical,
      },
      {
        id = "site-well-known",
        section = "Website Security",
        description = "Any website directory must contain a .well-known directory",
        probe = "for d in www site docs/site; do if [ -d \"$d\" ]; then test -d \"$d/.well-known\" || exit 1; fi; done",
        severity = 'warning,
      },
      {
        id = "site-resource-records",
        section = "Website Security",
        description = "Any website directory must contain resource-record templates (resource_records/, or dns/records/ in the issue-53 canonical layout)",
        probe = "for d in www site docs/site; do if [ -d \"$d\" ]; then { test -d \"$d/resource_records\" || test -d \"$d/dns/records\"; } || exit 1; fi; done",
        severity = 'warning,
      },
    ],
  },

  # -------------------------------------------------------------------
  # Variance schema — P-shape scoped exceptions per verification.
  # A variance suppresses a specific verification's obligation for a
  # reason, with approver + expiry. Because trust is BLOCKING authority,
  # variances on trust entries are SIGNIFICANTLY more consequential than
  # variances on intend (reporting) entries — variance approver MUST
  # be the repo maintainer or above for critical-severity entries.
  # -------------------------------------------------------------------
  # A record SHAPE (contract-only fields, no values): kept out of `nickel export`.
  variance_schema | not_exported = {
    entry_id     | String,   # which verification / probe id
    reason       | String,
    approved_by  | String,   # maintainer or above for critical entries
    scope        | String,   # path glob | session-id | "until-<date>"
    expires      | String,   # absolute date; trust variances cannot be open-ended
    review_notes | String | optional,
    # Additional trust-specific guardrails:
    severity_acknowledged | [| 'critical, 'high, 'medium, 'low |],
    waived_risk_description | String,  # plain language — what is being accepted
  },

  # -------------------------------------------------------------------
  # Execution policy
  # -------------------------------------------------------------------
  execution = {
    # When the component runs.
    # pre_push + pre_commit on anything touching security-adjacent files
    # + session_close (drift check) + on_demand.
    triggers = [ 'session_close, 'on_demand, 'pre_push, 'pre_commit_security_adjacent ],

    # Per-verification execution. Failed verification = blocked merge.
    per_verification = {
      run_probe = true,
      record_outcome = true,
      respect_variance = true,    # active variance suppresses the gate
      on_unmet = 'fail,           # BLOCKING — the opposite of intend's 'log_drift
      severity_escalation = 'honour,  # critical > high > medium > low in gate decisions
    },

    # Per-safe-hacking-probe execution.
    # If a probe FINDS what it was supposed to prevent finding
    # (e.g. injection succeeds, auth-bypass works), that's an EXPLOIT
    # demonstration — hard fail, regardless of other status.
    per_probe = {
      run_probe = true,
      record_outcome = true,
      honour_expected_outcome = true,
      on_unexpected_exploit_success = 'fail,  # exploit found where it shouldn't be
      scope_enforcement = 'this_repo_only,    # never touch external systems
      timeout_honouring = 'strict,
    },

    # Evidence sinks — BOTH written, every execution.
    evidence_sinks = [
      {
        kind   = 'verisimdb,
        table  = "contractile_executions",
        schema = "contractile_execution_v1",
        # trust-specific sub-table for probe outcomes (for threat-model audit)
        aux_tables = [ "trust_verifications", "trust_probes" ],
      },
      {
        kind        = 'drift_log,
        path        = ".machine_readable/descriptiles/drift_praxis.deed",
        append_only = true,
      },
    ],

    # Session-close hook — re-verify EVERYTHING, re-run probes, diff
    # against last ratification. The "turn off the firewall" scenario
    # must be caught here if it wasn't caught at pre-push.
    on_close = {
      re_execute_all_verifications = true,
      re_run_all_safe_hacking_probes = true,
      diff_against_last_ratification = true,
      emit_drift_entries_for_new_failures = true,
      surface_expired_variances = true,
      # trust-specific: if any blocking-severity verification is newly
      # failing, the session close is BLOCKED from completing. User
      # cannot close a session with unresolved critical trust drift.
      block_session_close_on_critical_drift = true,
    },

    # -----------------------------------------------------------------
    # Session-open hook — NEGOTIATION + RATIFICATION + ACCOUNTABILITY
    # (inherited shape from intend.k9.ncl v2.0.0; trust-specific
    # additions around threat-model foregrounding below)
    # -----------------------------------------------------------------
    on_open = {
      # --- Context presentation ---
      render_summary = 'plain_language,    # metaphor-capture defense
      include_drift_log_from_last_close = true,
      include_active_variances = true,
      include_recent_anchors = true,
      anchor_lookback_weeks = 8,

      # trust-specific: the threat model is rendered FIRST, before any
      # negotiation, so the adversary and stakes are fresh in both minds.
      # This directly defends against B1 (threat-model misclassification)
      # — the "war reporter, generic personal-website priors" scenario.
      threat_model_foregrounding = {
        required = true,
        render_adversaries = true,   # from Trustfile [THREAT_MODEL]
        render_stakes = true,
        render_compliance_regimes = true,
        render_audience_sensitivity = true,
        # If the AI is about to suggest a trust-weakening action, it
        # must re-render the threat model before the suggestion lands.
        re_render_before_weakening_suggestion = true,
      },

      # --- Negotiation phase (five mandatory inputs, inherited) ---
      negotiation = {
        required = true,
        ai_required_inputs = [
          'timeline_realism,
          'industry_standards,        # especially relevant for trust: OWASP, NIST, PCI-DSS, GDPR
          'audience_feasibility,      # who is the adversary? who is protected?
          'resulting_invariants,      # what trust entries the work creates/amends
          'ecosystem_dependencies,    # TLS libs, crypto primitives, signing infra
        ],
        user_engagement_required = true,
        user_engagement_mode = 'per_input_response,
        specification_translation = {
          ai_produces_spec_form = true,
          user_reviews_in_domain_language = true,
          schema_authoring_is_ai_responsibility = true,
          translation_faithfulness_auditable = true,
          # trust-specific: the AI's translation includes rendering
          # cipher suites, key exchange choices, rate-limit numbers in
          # domain language ("strong encryption, PQ-resistant, 60 req/min")
          # rather than forcing the user into Nickel-schema authoring.
        },
      },

      # --- Accountability pledge (both parties, explicit) ---
      # trust's pledge is MORE stringent than intend's because the
      # authority is blocking. A user accepting accountability here is
      # accepting that security-affecting decisions have blocking consequence.
      accountability_pledge = {
        required = true,
        parties = [
          {
            role = 'user,
            pledge = "I have reviewed the threat model, the declared trust obligations, and the audience/stakes consequences. I accept accountability for meeting these obligations and understand that failed verification will block merges until resolved or varied. I will not attempt to disable verification to unblock a merge; I will raise a variance or amendment instead.",
            signature_required = true,
          },
          {
            role = 'ai_agent,
            pledge = "I will hold the line on declared trust obligations. I will refuse to 'disable' verifications to unblock merges; I will refuse security-weakening suggestions that contradict the threat model even when the user is enthusiastic; I will surface drift at session close; I will re-render the threat model before proposing any weakening action. If a legitimate scope shift demands security reduction, I will require a variance with severity acknowledgement or an amendment, not silent acceptance.",
            signature_required = true,
          },
        ],
        signed_record_destination = ".machine_readable/descriptiles/ratification-<session-id>_praxis.deed",
        must_precede_work = true,
      },

      ratification_record_shape = {
        includes_negotiation_transcript = true,
        includes_both_pledges = true,
        includes_threat_model_snapshot = true,   # trust-specific
        signed = true,
        dated = true,
        session_id = 'required,
        contract_hash = 'required,
      },
    },
  },

  # -------------------------------------------------------------------
  # Failure-mode defenses — trust is the widest-coverage verb.
  # See feedback_ai_failure_mode_catalog.md for the full catalog.
  # -------------------------------------------------------------------
  failure_mode_defenses = [
    # Category A — enthusiasm / narrative capture
    'A1_enthusiasm_capture,            # scope breach blocks via blocking authority
    'A2_metaphor_capture,              # render_summary + re_render_before_weakening
    # Category B — threat-model misclassification (trust's flagship defense)
    'B1_threat_model_misclass,         # threat_model_foregrounding = required
    'B2_audience_sensitivity_collapse, # audience_feasibility in negotiation
    'B3_compliance_prior_drift,        # industry_standards in negotiation
    # Category C — scope/capability erosion (the "firewall off" scenario)
    'C2_capability_collapse,           # blocking gate prevents silent capability drop
    'C3_helpfulness_inflation,         # trust-affecting changes need variance/amendment
    'C4_modernization_drift,           # unrequested crypto-lib upgrade caught
    # Category D — epistemic failures
    'D4_error_hiding,                  # on_unmet = 'fail makes hiding impossible
    'D5_sycophancy,                    # pledge forces AI to hold line against enthusiasm
    'D6_false_pessimism,               # negotiation requires AI to cite constraint, not assert impossibility
    # Category E — refactor/churn
    'E4_cargo_cult_security,           # probes VERIFY the claimed protection actually runs
    # Category F — session drift
    'F1_across_session_forgetting,     # on_open reads last-ratification, drift log, recent ANCHORs
  ],
}
