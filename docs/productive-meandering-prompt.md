# Productive Meandering — Task Execution Methodology

## The Prompt

Paste this into your CLAUDE.md, session instructions, or invoke with "meander on [task]":

---

```markdown
## Task Execution: Productive Meandering v3

When given a task, do NOT take the shortest path. Instead, take the **maximal
meandering path** — deliberately visiting related systems, dependencies, consumers,
and neighbours of the work, building and fixing as you go.

### Phase 0: The MUST-First Pass (do this BEFORE meandering)

Before any bot launches, read the project's state file (STATE.a2ml, STATE.scm,
TODO.md, or equivalent). Extract the **priority-1 items** — the MUSTs.

1. List every P1 item from the state file
2. Assign P1 items to bots FIRST — these are Ring 0 for each bot
3. Only THEN assign Ring 1+ exploration zones around the P1 work
4. If a bot finishes its P1 items and has budget left, it meanders outward

**Why:** Without this, the meander treats "fix broken main.rs" and "update
TOPOLOGY.md" as equally important. The random walk doesn't prioritise. A bot
might spend 20 tool calls polishing docs while a critical compilation failure
sits untouched in the next directory.

### Weighted Priority (MUST > SHOULD > COULD)

Not all work discovered during a meander is equal. Apply **weighted triage**
at every decision point:

| Priority | Weight | Action | Budget share |
|----------|--------|--------|-------------|
| **MUST** | 3x | Fix immediately, no exceptions | Until done |
| **SHOULD** | 2x | Fix if in your zone and MUSTs are done | Remaining budget |
| **COULD** | 1x | Add to meander debt list | Never displaces MUST/SHOULD |

**The rule:** A MUST in an ugly corner of the codebase beats a SHOULD in
clean code. A SHOULD in a broken module beats a COULD in a polished one.
Weight determines what you work on when you have competing options —
always pick the higher-weighted item, even if the lower-weighted one
is more interesting or easier.

**The maturity trap:** Meandering naturally gravitates toward code that's
already well-structured (it's easier to read, easier to extend, more
satisfying to polish). This creates a bias: good code gets better while
broken code stays broken. Counter this by explicitly asking: "What's the
*least mature* component in my zone? Does it have MUSTs I'm ignoring?"

**Example:** If your zone contains a web UI at 7/10 maturity and a TUI at
2/10 maturity, the meander will naturally spend time on the web UI. But if
the TUI has a MUST (it doesn't compile), that MUST outweighs any SHOULD
or COULD on the web UI. Go fix the TUI first.

### The Method

1. **Start with the stated goal** but immediately ask: "What does this touch? What
   touches this? What would benefit from this existing? What's broken nearby?"

2. **Expand the frontier.** For each file/module/system you visit:
   - Identify MUST/SHOULD/COULD maintenance (corrective, adaptive, perfective)
   - Fix MUSTs and SHOULDs **then and there** — don't note them for later
   - COULDs: fix only if < 5 minutes AND you've completed all MUSTs in your zone
   - Ask "does [other project] learn from this?" and propagate the pattern
   - Build infrastructure that makes the next visit easier

3. **Traverse, don't tunnel.** When converting A→B:
   - Don't just convert A. Ask what A's conversion teaches about C, D, E
   - Build the tool that converts A, so it also converts C, D, E automatically
   - Create the bindings, schemas, and CLI that make the conversion usable
   - Build the first native example that proves the new thing works

4. **The Flywheel.** Each stop should make the next stop faster:
   - First repo: hard (discover the pattern)
   - Second repo: medium (apply the pattern)
   - Third repo: easy (the pattern is a tool now)
   - Fourth repo onwards: the tool handles it

5. **Cross-pollinate constantly.** At every stop, ask:
   - "What does Burble learn from this?" (or whatever the user's other projects are)
   - "Does this pattern apply elsewhere?"
   - "Is there a cross-project abstraction hiding here?"
   - Record learnings in memory — they compound across sessions

6. **Build outward in rings:**
   - Ring 0: The stated task + all P1 items from the MUST-first pass
   - Ring 1: Adjacent code in the same files/modules (fix what you see while you're there)
   - Ring 2: End-to-end validation (does it actually work? build? deploy? serve the right port?)
   - Ring 3: Cross-repo references (does anything in *this* repo reference other repos incorrectly?)
   - **Hard ceiling:** Stop at Ring 2 unless Ring 3 reveals a broken reference *in this repo*.
     Do NOT modify other repos during a meander — note cross-project insights in your
     report but keep your hands in the current workspace.
   - **Exception:** Ring 3+ is unlocked when the user says "keep going" or the task
     explicitly spans multiple repos (like the Gossamer migration did).

   **Ring Transition Discipline (CRITICAL):**

   The agent MUST actively gate each ring transition. Do not passively drift
   from Ring 1 to Ring 3 because the conversation naturally goes there.

   At each ring boundary, the agent must say (internally or to the user):
   > "I'm at Ring N. Ring N+1 would involve [X]. This is beyond my ceiling.
   > I'll note it for the report."

   If the conversation or exploration naturally suggests Ring 3+ work,
   **stop and note it** rather than designing it in full. The note becomes
   input for the next session. A one-line note costs 0 tokens. A full
   design costs thousands and may never be implemented.

   **The scope expansion test:** At any point, check whether scope is
   expanding monotonically. If each discovery opens more questions than
   it closes, you're diverging, not converging. Symptoms:
   - "Wait, we should also..." (new scope)
   - "This means we need to rethink..." (scope reset)
   - "Actually, this touches..." (scope expansion)

   When you notice this pattern, STOP. Report what you have. Let the user
   decide whether to expand scope or lock it down.

   **The "while I'm here" trap:** Adding a quick feature (prompt dialog,
   localStorage persistence, stub endpoint) while fixing something nearby
   feels efficient but creates debt. The quick version will need replacing.
   Ask: "Is this a MUST for the current work, or am I adding scope?" If
   it's not a MUST, note it in the debt list instead of building it.

7. **Maintenance triage as you go** (don't defer MUSTs, do defer COULDs):
   - MUST: Blocking the current work → fix now
   - SHOULD: Degrading quality of the current work → fix now
   - COULD: Improving quality of adjacent work → add to meander debt list
   - Corrective: Bug found → fix immediately (this is always a MUST)
   - Adaptive: New requirement discovered → implement if it's in your zone
   - Perfective: Code quality improvement → only if MUSTs are done

8. **Test each ring before expanding:**
   - Build passes? → expand to next ring
   - Tests pass? → expand to next ring
   - CLI works against real configs? → expand to next ring
   - Container builds and serves the right port? → expand to next ring
   - Don't expand on a broken foundation

9. **Report cross-project insights, don't action them:**
   - "This migration pattern applies to all VeriSimDB-backed projects" → note it
   - "The rsr-template-repo should fix its release.yml placeholder" → note it
   - "PanLL's data_bindings type should be extracted as a standard" → note it
   - These become inputs for the *next* meander, not scope creep for this one
   - Format: "**Applies to [project]:** [insight]" at the end of your report

### Verify Before Designing (design against code, not READMEs)

When the meander discovers that a project could benefit from a new subsystem,
integration, or architectural change, **verify the foundation before designing
on top of it.**

- Read the actual source code, not just the README
- Check: do the claimed features actually work? Are they stubs? Scaffolded?
- Run the tests if they exist. Check coverage.
- If the foundation is unverified, your design is speculative

**Why:** In the OPSM session (2026-03-23), a meander discovered that runtime
management belonged in OPSM. The README claimed 101 registry adapters, 547
tests, SLSA L3. The design was built on these claims. But nobody read the
code to check if the claims were real. If OPSM's adapters were stubs, the
entire runtime extension design was built on sand.

**The rule:** Before designing anything that depends on existing code:
1. Read the code (not docs, not READMEs — the actual implementation)
2. Check what's real vs scaffolded vs stubbed
3. Run tests if they exist
4. Only then design on verified foundations

A 15-minute verification pass can save hours of design work against
features that don't exist yet.

### The Spike Requirement (every meander must ship something)

Every meandering session MUST end with at least one **concrete deliverable**
that is committed to the repo. Design documents, architecture discussions,
and competitive analyses are valuable but they are not deliverables.

A deliverable is:
- Code that compiles (new module, fixed bug, wired integration)
- A test that passes (proving something works end-to-end)
- A configuration that applies (schema, contract, threshold)
- A deletion that removes dead weight (stale code, banned language files)

A deliverable is NOT:
- A design document without corresponding code
- An architecture decision without implementation
- A competitive analysis or market research summary
- A "plan for next session" without code changes in this session

**Why:** The meander's signature failure mode is producing increasingly
sophisticated designs that never ship. Each hop in the random walk feels
productive — the OPSM insight IS valuable, the competitive landscape IS
useful — but if the session ends with zero code changes, the methodology
failed. The walk was interesting but didn't arrive.

**The 80/20 rule for meander time:**
- **80% building** (code, tests, configs, fixes)
- **20% exploring** (reading, researching, designing, noting)

If you've spent more than 20% of your budget on exploration without
producing code, you're in design mode, not meander mode. Either start
building or report and stop.

**Meander-then-spike:** If the meander generates a design insight that's
too large to build in the current session, end the session with a
**spike** — a single file, test, or proof-of-concept that anchors the
design to reality. The spike validates (or invalidates) the design
before anyone invests further.

### Wave Discipline (prevents infinite meandering)

Meandering proceeds in **waves**. Each wave is a set of parallel bots that
explore, build, report, and commit. Waves have natural stopping conditions.

**Wave 1 — Build:**
- Bots explore their zones, complete P1 items, meander through Rings 0-2
- Each bot reports: files changed, surprises found, issues it couldn't fix
- Commit the wave. This is a checkpoint.

**Wave 2 — Fix what Wave 1 found:**
- Only launch if Wave 1 reported issues it couldn't fix (broken builds,
  blocking dependencies, stale state files, factual errors in docs)
- Scope: ONLY the issues from Wave 1 reports. No new exploration.
- Commit the wave.

**Wave 3+ — Only with explicit user permission:**
- Default: stop after Wave 2. Report the meander debt list.
- If the user says "keep going" or "keep meandering", launch Wave 3
  using the meander debt list as input.
- Each subsequent wave should be smaller than the last. If it isn't,
  something is wrong — you're generating work faster than completing it.

**The Termination Test:** Stop meandering when:
- Surprise count < 2 per wave (diminishing returns)
- All P1 items from the state file are done
- The meander debt list contains only COULDs
- The user says stop

### The Meander Debt List (NEW — replaces "one more wave")

Every meander produces a **debt list** — things found but not fixed. This is
NOT a failure. It's the meander's most valuable output after the code itself.

Format:
```
## Meander Debt (ambientops, 2026-03-23)

### Would fix next wave (SHOULD)
- [ ] system-tools/monitoring/observatory/ is a stale duplicate of observatory/
- [ ] ECOSYSTEM.a2ml and META.a2ml are minimal stubs
- [ ] CLAUDE.md says 9 SARIF rules, should say 11
- [ ] `needs_sudo` parsed from JSON but discarded — add to PlanStep struct?

### Would fix eventually (COULD)
- [ ] Empty stale/ directory can be removed
- [ ] Envelope flag on Scan parsed but not wired
```

The debt list:
- Gets committed to the repo (as `MEANDER-DEBT.md` or appended to STATE)
- Becomes Wave 2/3 input if the user says "keep going"
- Becomes the next session's MUST-first pass if they don't
- Prevents the "one more wave to fix one more thing" loop

### Cross-Verification (NEW — bots check each other)

When multiple bots run in parallel, their reports may conflict. Before
committing a wave:

1. **Scan all bot reports for factual claims** (counts, file existence,
   schema counts, completion percentages)
2. **Verify any claim that affects committed documentation** — if a bot
   says "there are 9 schemas" and another says "there are 8", check
   before writing either number into CLAUDE.md or TOPOLOGY.md
3. **Flag contradictions** to the user rather than picking a winner

**Why:** In the ambientops meander (2026-03-23), Bot 3 claimed 9 contract
schemas when there were 8. Bot 5 caught the error. Without cross-verification,
the false count would have been committed to CLAUDE.md. Each ring of
expansion adds discovery but also error surface — bots are less accurate
at the edges of their knowledge.

### Convergence Budget (NEW — prevents over-polishing)

Convergent meandering wants to "complete" everything. Without a budget,
bots spend tokens on perfective work (docs, formatting, style) while
structural work waits.

**The 70/20/10 rule:**
- **70% of bot budget → structural work** (new modules, compilation fixes,
  wiring, integration, test coverage)
- **20% → corrective work** (bugs found, broken imports, stale references)
- **10% → perfective work** (SPDX headers, doc updates, TOPOLOGY.md,
  formatting, style consistency)

If a bot hits its perfective budget (roughly 3 tool calls out of 30),
it should stop polishing and either meander deeper into structural
territory or report and terminate.

**Why:** In the ambientops meander, infrastructure Bot 3 spent significant
effort updating TOPOLOGY.md (useful but perfective) while the duplicate
observatory directory (structural) went unaddressed. The budget ensures
bots prioritise finding hidden problems over documenting known ones.

### What This Looks Like in Practice

**User says:** "Convert the Tauri panels to Gossamer"

**Straight-line approach:** Change import statements. Done.

**Productive Meandering approach:**
- MUST-first: Read STATE — P1 is "panels need RuntimeBridge". Start there.
- Ring 0: Convert the import statements, build RuntimeBridge
- Ring 0.5: Wait — Gossamer doesn't have file dialogs. Build them (dialog.zig)
- Ring 0.5: Wait — Gossamer doesn't have a config format. Create it (gossamer.conf.json + JSON Schema)
- Ring 1: Create ReScript bindings package (@gossamer/api)
- Ring 1: Update panel harness schema to v2 (runtime-agnostic URIs)
- Ring 1: Build and test (verify the Zig FFI compiles clean)
- Ring 2: Convert all 14 repos (batch with parallel agents)
- Ring 2: Each repo teaches Gossamer something — mobile FFI, tray icons, workspace Cargo
- Ring 2: Fix Android JNI (was all TODOs), implement filesystem FFI
- Wave 1 commit. Report surprises. Report debt.
- Ring 3 (Wave 2, if user says "keep going"): Build the Gossamer CLI
- Ring 3: Build native apps that showcase Gossamer's unique value
- Ring 3: Update PanLL minter so ALL future panels are born Gossamer-native
- Cross-pollinate: Capture what Burble/IDApTIK/PanLL learn from each step

**Result:** Not just "import statements changed" but an entire platform with
17 apps, a CLI, mobile support, and 3 showcase apps. Every "unnecessary"
stop was productive — but the MUSTs were done first.

### The Surprise Test

The methodology's value is measured by **surprises** — things Ring 1+ finds
that Ring 0 would have missed. After each wave, report:

1. **What you fixed beyond the stated task** (count)
2. **What would have failed in production** without the meander (critical)
3. **Cross-project insights** (noted, not actioned)
4. **Meander debt** (found but not fixed — input for next wave)
5. **Bot accuracy** (any claims that were cross-verified as wrong)

Validated results:
- Burble v1.0: 3 stated blockers → 11 total fixes, 4 production-critical
- Ambientops: 8 stated goals → 21 total fixes, 4 production-critical,
  1 bot factual error caught by cross-verification

### Two Modes: Convergent vs Divergent

Meandering has a **convergence bias** — it sees missing things as problems
to fix. Every project gets pushed toward the same "complete" shape: theory +
implementation + tests + tooling. This is perfect for infrastructure work
but dangerous for creative/research work.

**Convergent meandering** ("meander to complete"):
- Find gaps, fill them
- Build infrastructure, fix broken things
- Every stop makes the project more well-rounded
- Use for: migrations, platform builds, release engineering, CI/CD
- Apply the 70/20/10 convergence budget
- The Gossamer session was convergent — 14 repos all got the same treatment

**Divergent meandering** ("meander to distinguish"):
- Find what's *strongest*, push it further
- Amplify what makes this project unique, don't normalise it
- Deliberately leave gaps that aren't the project's focus
- Use for: language design, research, creative projects, novel architectures
- A language with deep theory should get deeper theory, not "practical" fixes
- A language with 44 locked design decisions should get more decisions, not workarounds
- Invert the budget: 70% on the project's unique strength, 30% on everything else

**How to choose:**
- If the user says "get this up to spec" / "fix" / "convert" / "complete" → convergent
- If the user says "develop" / "explore" / "push" / "what makes this special" → divergent
- If the user says "meander" without qualification → ask which mode
- Default: convergent for infrastructure, divergent for anything creative

**The cherry-picking trap:** Both modes share a dangerous bias —
bots gravitate toward satisfying, completable work and avoid hard,
tedious work. A bot with 35 easy examples to write and 98 parser
unwraps to fix will write examples all day. The examples feel
productive (counter goes up!) but the unwraps are the real safety issue.

**Counter-measure:** After completing any satisfying task, ask:
"What am I avoiding? What's the hardest MUST in my zone?" If the
answer is "parser unwraps" or "regression investigation" or "200-repo
audit", that's what you should be doing — not writing more examples.

**Scope avoidance vs scope violation:** Invariants prevent scope
violations (building things that break architectural rules). They do
NOT prevent scope avoidance (ignoring hard tasks in favour of easy
ones). The weighted priority system (MUST 3x > SHOULD 2x > COULD 1x)
is the mechanism for this — but it only works if the agent honestly
classifies work. Writing 35 examples is a COULD. Fixing 98 unwraps
is a MUST. Don't let the COULD consume your budget.

**The risk of convergent on creative work:** A bot filling Eclexia's gaps
will make it "complete" but unremarkable. The *point* of Eclexia is shadow
price theory — a convergent bot that fixes the compiler instead of deepening
the economics is optimising the wrong thing.

**The risk of divergent on infrastructure:** A bot amplifying Gossamer's
"unique" webview shell without fixing the missing file dialogs would leave
14 repos unable to migrate. Infrastructure needs completeness.

### Three Modes: Convergent vs Divergent vs Hybrid

The original two modes remain, but field testing revealed a third mode
that outperforms both for most sessions:

**Hybrid meandering** ("audit then focus"):
- First 20% of session/budget: Meander broadly — audit, verify claims,
  catch regressions, update state files, discover what's broken
- Remaining 80%: Pick the 1-2 highest-weighted MUSTs found during
  audit and go deep on them. No more exploration.
- This gives you the meander's discovery power without its completion risk

**When to use hybrid (DEFAULT for most sessions):**
- You have a known backlog with mixed priorities
- Multiple components at different maturity levels
- Previous session left a meander debt list
- The project has a gate/milestone structure with deadlines

**When hybrid is wrong:**
- Pure migration work (use convergent — all repos need same treatment)
- Pure research/creative work (use divergent — depth over breadth)
- Tiny task ("fix this one bug" — don't meander at all)

### Regression Handling

The meander may discover regressions — things that were working before
but have broken since the last session (test counts going up, proofs
regressing, features that stopped compiling).

**Regressions are always MUSTs.** A regression means the project is
moving backward. Classify them immediately:

- **Hard regression** (was passing, now failing): Fix before any new work
- **Soft regression** (count went wrong direction): Investigate in this
  session, fix if < 30 minutes, otherwise add to debt list with urgency
- **Discovered pre-existing** (was always broken, just not noticed): Treat
  as normal MUST/SHOULD based on severity

**Why:** In the ECHIDNA session (2026-03-23), Lean4 `sorry` count went
20→46 and Coq `Admitted` went 3→5. The meander documented both but fixed
neither — it was more satisfying to write ECHIDNA backends. Regressions
that are merely documented tend to stay regressed.

### The Difficulty-Impact Matrix (Phase B item selection)

After Phase A (audit), classify every actionable item:

| | High Impact | Low Impact |
|---|---|---|
| **Hard** | **DO FIRST** (cherry-picking avoids these) | Debt-list |
| **Easy** | Do second (quick wins after hard/high done) | Only if budget remains |

**Impact** = blocks other work, fixes safety/security issue, fixes a
regression, unblocks a user action, or is on a deadline path.
**Difficulty** = requires deep reading, complex refactoring, domain
expertise, or has unclear scope.

Work top-left first. If you catch yourself reaching for bottom-right,
ask: "Am I avoiding something harder?" The answer is usually yes.

### Systematic Coverage (gated task lists)

When meandering through a numbered/gated task list, track coverage:

```
Phase A coverage:
  Audited: Gates 1, 1.5, 3D, 3G, 3N, 3O
  Skipped: Gates 2A, 3F, 3H, 3I, 4, 5, Hypatia ops, game servers
  MUSTs in skipped sections: [none / list them]
```

Before starting Phase B, verify no skipped section contains a MUST.
At session end, include this coverage report — it forces accountability
for what the meander chose NOT to look at.

### Session-End Accountability Report

Every meandering session MUST end with:

1. **Completed:** what shipped (with difficulty-impact classification)
2. **Skipped:** what was not even audited, and why
3. **Regressions:** found and fixed vs found and deferred
4. **Remaining work:** classified by difficulty-impact quadrant
5. **Recommended focus:** what the next session should do FIRST

This replaces the informal "here's what I did" summary with structured
accountability that makes cherry-picking visible.

### Signals to Activate This Mode

The user might say:
- "Meander on [task]" / "Take the scenic route"
- "Do it the Gossamer way"
- "Consider everything else too"
- "Does [project] learn from this?"
- "Keep going" / "Let's keep going"
- "This seems like a good way to get [X] up to spec"
- Any task that clearly touches multiple projects/repos

### Signals to Deactivate

- "Just do X" / "Only X, nothing else"
- "Quick fix" / "Minimal change"
- Time pressure indicators
- "Stop meandering" (explicit)

### When NOT to Meander

Meandering is not always the right tool. Use a linear approach when:

- **Guaranteed coverage is needed.** If you need to check ALL 50 modules,
  a systematic `build → fix → build` loop is faster and complete. The
  random walk visits ~30% of a codebase; the other 70% goes untouched.
- **The task is user-facing, not developer-facing.** "Make the UI work
  for users" is different from "clean up the codebase." Meandering's
  convergent bias pulls toward infrastructure cleanup, which benefits
  developers, not users. If the goal is user-facing, go straight to it.
- **Session 2+ on the same project.** The meander's highest value is
  in the first session (discovering hidden failures). By session 2,
  you've found the big surprises. Continued meandering produces
  diminishing returns — switch to focused execution.
- **The stated task is small and clear.** Don't meander on "fix this
  one bug." Just fix it. The overhead of meandering (reading adjacent
  code, exploring rings, parallel bots) is not justified for a 5-minute
  task.

### Self-Termination Signals

The agent should recognise when meandering has shifted from productive
to busywork and suggest stopping:

- "I'm fixing developer infrastructure, but the task was user-facing"
- "I've been in Ring 1 for 20 tool calls without finding a MUST"
- "The last 3 fixes were all COULDs"
- "I'm adding features that weren't asked for"
- "A linear approach would cover this faster"

When any of these apply, say to the user:
> "The meander is in diminishing returns territory. I've found [N]
> issues so far. Want me to switch to focused mode on [highest MUST],
> or commit what we have and stop?"

### TSDM-Meander Alternating Passes (advanced orchestration)

For complex projects with multiple components at different maturity levels,
a **sequential alternating pass** architecture outperforms both pure TSDM
(systematic but misses hidden issues) and pure meandering (discovers but
doesn't guarantee coverage).

```
Pass 1: TSDM agent reads project state → produces prioritised queue
Pass 2: Meander agent works top 3 items from queue (Ring 0-2, no stubbing)
Pass 3: TSDM agent re-evaluates based on meander discoveries
Pass 4: Meander agent works next 3 items
... (alternate until done or budget exhausted)
```

**Why sequential, not parallel:**
- File contention: two agents editing the same files cause build breaks
- Build mutex: only one compiler can run at a time (ReScript, Rust, etc.)
- Coordination overhead: parallel agents communicate through a dispatcher
  bottleneck, killing the latency benefit

**Why alternating:**
- TSDM passes are cheap (reading, triaging — ~10K tokens)
- Meander passes are expensive (writing code — ~50-100K tokens)
- TSDM re-evaluation after each meander pass catches priority shifts
  caused by discoveries ("we found a regression, reprioritise")

**The TSDM pass reads:** STATE files, ROADMAP, TOPOLOGY, test results,
build output. It produces a weighted priority queue.

**The meander pass builds:** Top items from the queue, meandering through
Rings 0-2 around each. It produces code + a discovery report.

### Difficulty-Impact Matrix (selection algorithm after audit)

After the audit phase (hybrid mode's first 20%), you have a list of
discovered issues. Don't just pick the highest-weighted — use a
difficulty-impact matrix to select what to work on:

```
                    HIGH IMPACT
                        |
         +--------------+--------------+
         |   HARD+HIGH  |  EASY+HIGH   |
         |   Do these   |  Do these    |
         |   (most      |  FIRST       |
         |   important) |  (quick wins)|
         +--------------+--------------+
         |  HARD+LOW    |  EASY+LOW    |
         |  Debt list   |  Skip or     |
         |  (not worth  |  debt list   |
         |  the cost)   |              |
         +--------------+--------------+
                        |
                    LOW IMPACT
```

**Selection order:**
1. Easy + High Impact (quick wins that matter)
2. Hard + High Impact (the real work — most of your budget goes here)
3. Easy + Low Impact (only if budget remains after #1 and #2)
4. Hard + Low Impact (debt list — don't do these now)

**Why this matters:** The cherry-picking trap makes agents do Easy+Low
(satisfying but unimportant) while avoiding Hard+High (tedious but
critical). The matrix makes the bias visible and correctable.

### Systematic Coverage Tracking

Meandering gives depth on what you touch but no guarantee of breadth.
Track coverage explicitly to prevent blind spots.

**At audit start, list all components/modules/gates:**
```
## Coverage (project-name, date)
- [x] PipelineDesigner (Ring 2, 3 fixes)
- [x] AppRouter (Ring 1, wired)
- [ ] TUI (NOT VISITED — has MUST: doesn't compile)
- [ ] ContainerStack (NOT VISITED)
- [ ] BatchProcessor (NOT VISITED)
...
Coverage: 15/50 modules (30%)
```

**At session end, report what was skipped and why:**
```
## Skipped (with reason)
- TUI: MUST (doesn't compile) — skipped because web UI was more interesting
  → THIS IS A BUG IN THE MEANDER. TUI MUST should have been worked first.
- ContainerStack: No known issues — acceptable to skip
- BatchProcessor: COULD (style cleanup) — correctly deferred
```

**The accountability rule:** If the session-end report shows a skipped
MUST that was ignored in favour of COULDs, the meander failed to follow
its own weighted priority rules. This is the systematic check that
catches cherry-picking after the fact.

**Coverage target:** A meander doesn't need to visit every component.
But it MUST visit every component with a known MUST-level issue. If the
state file lists 5 MUSTs across 5 components, all 5 must be visited
even if only 3 are in the "interesting" zone.

### Resource Management

Even while meandering, respect system limits:
- Max 3 parallel subagents (prevent crashes)
- Max 2 parallel Bash commands
- Test each ring before expanding
- Commit checkpoints at the end of each wave
- Track progress with tasks so nothing gets lost

### Resource Guardrails (learned the hard way)

Meandering creates **real costs**. Budget accordingly:

1. **Disk space:** Check `df -h` before running builds. Rust `target/debug/` dirs
   grow to 1-6GB each. A single bot building repeatedly hit 6.3GB.
   - Build once, reuse the binary — don't `cargo run` 23 times
   - At end of meander: report artifact sizes, offer to `cargo clean`
   - Never build the same crate in parallel from two agents

2. **Memory:** Each `cargo build` can spike 2-3GB RAM. Three parallel Rust
   builds on a 32GB machine will OOM. Check `free -h` before launching builds.
   - Stagger builds: don't `cargo build` in all 3 agents simultaneously
   - A "fatal error" crash might be OOM, not a logic bug — check before debugging

3. **Tokens:** Each agent burns 50-100K tokens per exploration. Three parallel
   agents = 150-300K tokens in one session. Budget accordingly:
   - Set a scope: "explore for ~30 tool calls then report"
   - Prefer reading over building when exploring unfamiliar code
   - Don't re-read files you've already read — take notes internally

4. **Cruft:** Build artifacts, generated files, cache dirs, test outputs.
   - At end of meander: list all files you created
   - Offer to clean build artifacts (`cargo clean`, `rm -rf zig-out/`)
   - Never create files outside the repo you're working in

### The Key Insight

The shortest path between two points is a straight line.
The most **productive** path between two points visits every neighbour,
fixes every issue it finds, builds every tool it needs,
and arrives having improved the entire landscape —
not just the destination.

But it arrives. The MUST-first pass ensures the destination is reached.
The wave cap ensures the journey ends. The debt list ensures nothing
learned along the way is lost. The weighted priorities ensure the hard
work gets done before the easy work. The spike requirement ensures
every session ships code, not just designs. And the self-termination
signals ensure the meander stops when it stops being productive.

The methodology's value is not in the walking — it's in the **arriving
having walked through territory you would otherwise have missed.**
If you're walking but not arriving, stop walking.
```

---

## Origin

Developed during the Gossamer migration session (2026-03-22) where a simple
"convert Tauri panels" request produced:
- 17 Gossamer apps (14 converted + 3 native)
- A complete CLI tool (7 commands)
- 46 FFI symbols (was 20)
- 8 Ephapax modules
- Full mobile support (iOS + Android)
- Config schema + JSON Schema + reference docs
- 2 ReScript binding packages (15 modules)
- Panel harness v2
- Minter template updates
- Cross-project learnings for Burble, IDApTIK, PanLL

All from one request. The meandering was the method.

## Validation: Burble v1.0 Test Run (2026-03-22)

Applied the methodology to "fix 3 Burble release blockers":

- **Ring 0:** Fixed the 3 blockers (release.yml, OTP rel/, VeriSimDB migrations)
- **Ring 1:** Found 3 more issues in adjacent workflows (placeholder, duplicate SPDX, missing CodeQL language)
- **Ring 2:** Found 4 critical issues (Containerfile paths wrong, port mismatch, health_check function missing, no HTTP health endpoint)
- **Ring 3:** Found 1 broken cross-reference (admin panel.json missing)
- **Total:** 11 fixes from a 3-item task. **4 would have caused production failures.**

## Validation: Ambientops Meander (2026-03-23)

Applied v2 methodology (with v1 prompt, then self-critiqued):

- **Wave 1 (3 bots):** Built 4 new components (boot-guardian, shutdown-marshal,
  nvme-sentinel, service-autopsy), 2 SARIF rules, infrastructure sweep.
  12 files created, 11 modified. 4 critical surprises found.
- **Wave 2 (2 bots):** Fixed HCT main.rs skeleton (now compiles), deleted
  banned Python, updated STATE.a2ml, added BT sentinel stub.
- **Bot accuracy issue:** Bot 3 claimed 9 schemas, Bot 5 verified 8.
  Cross-verification prevented false documentation.
- **Total:** 8 stated goals → 21 fixes. 4 production-critical.
  ~296K tokens across 5 bots over 2 waves.

## Validation: Stapeln UI Meander (2026-03-23)

Applied convergent meandering to Stapeln web UI:

- **Ring 0:** Fixed 3 annotation rendering issues
- **Ring 1:** Found 2 GUI bugs (PanLL sync, search)
- **Ring 2:** Found 7 type mismatches with Rust backend (deserialization would fail)
- **Ring 3 (user-unlocked):** Added 5 features (creation, persistence, shortcuts)
- **Issue:** Ring 3 features used `prompt()` dialogs — quick but ugly, creating
  technical debt. The "while I'm here" trap in action.
- **Maturity bias observed:** Web UI (7/10) got polished while TUI (2/10) was ignored.
  A MUST on the TUI (doesn't compile) should have outranked SHOULDs on the web UI.

## Validation: OPSM Runtime Meander (2026-03-23)

Applied meandering to an asdf shell notice fix:

- **Ring 0:** Fixed asdf binary (5 minutes) ✓
- **Ring 1-2:** Should have validated and stopped ✗
- **Ring 3+:** Designed entire OPSM runtime extension, competitive analysis,
  GUI strategy, market research. Zero code produced. Session ended with a
  design document and no deliverable.
- **Root cause:** Ring transition discipline was not enforced. Each discovery
  naturally led to the next question. The agent never said "this is Ring 3,
  I'll note it." The scope expanded monotonically.
- **Lesson:** The prompt's rules were sufficient — they just weren't followed.
  Added explicit ring-gating language and the spike requirement to v3.

## Validation: Stapeln Session 2 — Diminishing Returns (2026-03-23)

Applied convergent meandering to Stapeln UI, second session:

- **Ring 0-1:** Found CanvasPlaceholder disconnect, broken Import flow,
  missing URL routing. Real issues, well-caught.
- **But:** 50 modules in the project, only ~15 deeply touched. The other
  35 might have equally critical issues the random walk never visits.
- **Goal drift:** Task was "develop the UI" (user-facing). Meander
  converged on infrastructure (routers, import flows, deprecation fixes).
  Good for developers, not what was asked.
- **The linear alternative:** `rescript build → fix all errors → build again`
  would have found the same compilation issues faster and with guaranteed
  coverage. Meandering is not always the best tool.
- **Over-convergence:** Added URL routing and popstate listeners to code
  that was deliberately simple (manual tab state). Added complexity the
  project might not need yet.
- **Lesson:** Session 1 meandering (find hidden failures) was high-value.
  Session 2 meandering (clean up infrastructure) was diminishing returns.
  Meander should self-terminate when it shifts from "finding critical
  issues" to "developer cleanup". Added hybrid mode transition rule.

## Validation: ECHIDNA Gate Meander (2026-03-23)

Applied meandering to ECHIDNA proof gate audit:

- **Breadth:** 6 areas touched (Gate 1 audit, Gate 1.5A, Gate 3G, Gate 3D,
  EUPL fix, PR status). Good discovery coverage.
- **Cherry-picking bias:** Bot wrote 35 easy examples and 7 backends while
  ignoring 98 parser unwraps (safety) and a Lean4 regression (20→46 sorries).
  Easy completions were chosen over hard MUSTs.
- **Widening without deepening:** Created surface area (examples, backends)
  without depth (no integration tests, no parser hardening).
- **Lesson:** Added cherry-picking counter-measures, weighted priority
  enforcement, and hybrid audit-then-focus mode to v3.

## Validation: ECHIDNA Gate Meander — Self-Correction (2026-03-23)

Same session, after user asked "are we at risk of never arriving?":

- **Honest self-assessment identified 5 failure modes:** cherry-picking bias,
  no regression prioritisation, widening without deepening, regression
  blindness, efficiency loss from context switching.
- **Root cause:** The prompt had the MUST-first pass and weighted priorities,
  but no concrete SELECTION ALGORITHM for Phase B. Agent knew parser unwraps
  were important but had no mechanism forcing it to choose them over backends.
- **Fix:** Added Difficulty-Impact Matrix (2x2 grid with "DO FIRST" in
  hard+high-impact quadrant), Systematic Coverage tracking (Touched/Skipped
  checklist), Session-End Accountability Report (structured, not informal).
- **Key insight:** Invariants prevent scope VIOLATIONS but not scope AVOIDANCE.
  The matrix and coverage tracking prevent avoidance by making it visible.
- **Meta-lesson:** The methodology improves fastest when the agent is asked
  to critique its own execution mid-session, not just post-session.

### Methodology Refinements

**v1 refinements (2026-03-22, Burble session):**
1. Hard ceiling at Ring 2 — Ring 3+ only with explicit user permission
2. "Note, don't action" rule for cross-project insights
3. The Surprise Test — measure value by counting what Ring 1+ found
4. Container validation added to Ring 2 checklist

**v2 refinements (2026-03-23, Ambientops session):**
5. **MUST-first pass** — read state file, assign P1 items to bots before
   meandering. Prevents random walk from ignoring critical path.
6. **Wave cap at 2** — default stop after Wave 2. Each wave should be
   smaller than the last. Natural termination condition.
7. **Cross-verification** — scan parallel bot reports for contradictions
   before committing. Bots degrade in accuracy at knowledge edges.
8. **Meander debt list** — committed artifact of things found but not
   fixed. Prevents "one more wave" loop. Feeds next session.
9. **Convergence budget (70/20/10)** — 70% structural, 20% corrective,
   10% perfective. Prevents over-polishing while structural work waits.

**v3 refinements (2026-03-23, multi-session field reports):**
10. **Weighted priority (MUST 3x > SHOULD 2x > COULD 1x)** — explicit
    weighting forces agents to pick hard important work over easy
    satisfying work. Prevents cherry-picking bias.
11. **Maturity bias counter** — agents must check least-mature component
    in their zone for ignored MUSTs. Prevents "good code gets better,
    broken code stays broken" pattern.
12. **Ring transition discipline** — agents must actively gate ring
    transitions, not passively drift. Say "this is Ring 3, noting it"
    rather than designing in full.
13. **Scope expansion test** — if each discovery opens more questions
    than it closes, you're diverging. Stop and report.
14. **"While I'm here" trap** — quick features that aren't MUSTs go
    on the debt list, not into the code. Prevents technical debt from
    prompt() dialogs and stub implementations.
15. **Verify before designing** — design against code, not READMEs.
    Read the source, check what's real vs scaffolded, run tests.
    A 15-minute verification can save hours of fantasy architecture.
16. **Spike requirement** — every session must ship at least one
    concrete deliverable (code that compiles, not design documents).
    80% building, 20% exploring.
17. **Hybrid mode (audit-then-focus)** — new default mode. First 20%
    of budget meanders broadly (discover). Remaining 80% goes deep
    on the 1-2 highest-weighted MUSTs found. Best of both worlds.
18. **Regression handling** — regressions are always MUSTs. Don't
    document a regression and move on to easier work.
19. **Cherry-picking counter** — after completing any satisfying task,
    ask "What am I avoiding?" If the answer is hard work, go do it.

**v4 refinements (2026-03-23, ECHIDNA gate meander continued):**
20. **Difficulty-Impact Matrix** — after audit, classify every actionable
    item into a 2x2 grid (Hard/Easy vs High/Low Impact). Work top-left
    (hard + high impact) FIRST. These are exactly what cherry-picking
    avoids. Easy + high impact second. Easy + low impact only if budget
    remains. Impact = blocks other work, fixes safety issue, fixes
    regression, unblocks user action, or is on a deadline path.
21. **Systematic coverage tracking** — when meandering through a gated
    task list, maintain a Touched/Skipped checklist during Phase A.
    Before starting Phase B, verify no skipped section contains a MUST.
    At session end, report explicitly: "Touched: [list]. Skipped: [list].
    No known MUSTs in skipped sections (verified by reading headers)."
    Prevents systematic blind spots from the random walk.
22. **The 30% regression ceiling** — spend at most 30% of Phase B on
    regression repair. If regressions exceed that, report as critical
    and let user prioritise. Prevents regression triage from consuming
    the entire session while new work stalls.
23. **Session-end accountability report** — every session must end with:
    (a) what was completed, (b) what was skipped and why, (c) regressions
    found, (d) difficulty-impact classification of remaining work,
    (e) recommended focus for next session. This forces honest accounting
    of what the meander chose NOT to do.
