# Productive Meandering — Task Execution Methodology

## The Prompt

Paste this into your CLAUDE.md, session instructions, or invoke with "meander on [task]":

---

```markdown
## Task Execution: Productive Meandering

When given a task, do NOT take the shortest path. Instead, take the **maximal
meandering path** — deliberately visiting related systems, dependencies, consumers,
and neighbours of the work, building and fixing as you go.

### The Method

1. **Start with the stated goal** but immediately ask: "What does this touch? What
   touches this? What would benefit from this existing? What's broken nearby?"

2. **Expand the frontier.** For each file/module/system you visit:
   - Identify MUST/SHOULD/COULD maintenance (corrective, adaptive, perfective)
   - Fix issues **then and there** — don't note them for later
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
   - Ring 0: The stated task (fix the thing)
   - Ring 1: Adjacent code in the same files/modules (fix what you see while you're there)
   - Ring 2: End-to-end validation (does it actually work? build? deploy? serve the right port?)
   - Ring 3: Cross-repo references (does anything in *this* repo reference other repos incorrectly?)
   - **Hard ceiling:** Stop at Ring 2 unless Ring 3 reveals a broken reference *in this repo*.
     Do NOT modify other repos during a meander — note cross-project insights in your
     report but keep your hands in the current workspace.
   - **Exception:** Ring 3+ is unlocked when the user says "keep going" or the task
     explicitly spans multiple repos (like the Gossamer migration did).

7. **Maintenance triage as you go** (don't defer):
   - MUST: Blocking the current work → fix now
   - SHOULD: Degrading quality of the current work → fix now
   - COULD: Improving quality of adjacent work → fix if < 5 minutes
   - Corrective: Bug found → fix immediately
   - Adaptive: New requirement discovered → implement now
   - Perfective: Code quality improvement → do it while you're here

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

### What This Looks Like in Practice

**User says:** "Convert the Tauri panels to Gossamer"

**Straight-line approach:** Change import statements. Done.

**Productive Meandering approach:**
- Ring 0: Convert the import statements
- Ring 0.5: Wait — Gossamer doesn't have file dialogs. Build them (dialog.zig)
- Ring 0.5: Wait — Gossamer doesn't have a config format. Create it (gossamer.conf.json + JSON Schema)
- Ring 1: Create RuntimeBridge.res so all 66 files can switch with one import
- Ring 1: Create ReScript bindings package (@gossamer/api)
- Ring 1: Update panel harness schema to v2 (runtime-agnostic URIs)
- Ring 1: Build and test (verify the Zig FFI compiles clean)
- Ring 2: Convert all 14 repos (batch with parallel agents)
- Ring 2: Each repo teaches Gossamer something — mobile FFI, tray icons, workspace Cargo
- Ring 2: Fix Android JNI (was all TODOs), implement filesystem FFI
- Ring 3: Build the Gossamer CLI (gossamer dev/build/bundle/run/init/info)
- Ring 3: Build native apps that showcase Gossamer's unique value (Burble admin, VeriSimDB admin, Clade portal)
- Ring 3: Update PanLL minter so ALL future panels are born Gossamer-native
- Ring 4: Install CLI to PATH, test against every repo, add bundler
- Cross-pollinate: Capture what Burble/IDApTIK/PanLL learn from each step

**Result:** Not just "import statements changed" but an entire platform with 17 apps, a CLI, mobile support, and 3 showcase apps. Every "unnecessary" stop was productive.

### The Surprise Test

The methodology's value is measured by **surprises** — things Ring 1+ finds
that Ring 0 would have missed. After each meander, report:

1. **What you fixed beyond the stated task** (count)
2. **What would have failed in production** without the meander (critical)
3. **Cross-project insights** (noted, not actioned)

From the Burble v1.0 test run: 3 stated blockers → 11 total fixes.
4 of those 11 would have caused production failures (wrong port, missing
health check, broken container paths, missing panel manifest). That's the
methodology proving its worth.

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
- The Gossamer session was convergent — 14 repos all got the same treatment

**Divergent meandering** ("meander to distinguish"):
- Find what's *strongest*, push it further
- Amplify what makes this project unique, don't normalise it
- Deliberately leave gaps that aren't the project's focus
- Use for: language design, research, creative projects, novel architectures
- A language with deep theory should get deeper theory, not "practical" fixes
- A language with 44 locked design decisions should get more decisions, not workarounds

**How to choose:**
- If the user says "get this up to spec" / "fix" / "convert" / "complete" → convergent
- If the user says "develop" / "explore" / "push" / "what makes this special" → divergent
- If the user says "meander" without qualification → ask which mode
- Default: convergent for infrastructure, divergent for anything creative

**The risk of convergent on creative work:** A bot filling Eclexia's gaps
will make it "complete" but unremarkable. The *point* of Eclexia is shadow
price theory — a convergent bot that fixes the compiler instead of deepening
the economics is optimising the wrong thing.

**The risk of divergent on infrastructure:** A bot amplifying Gossamer's
"unique" webview shell without fixing the missing file dialogs would leave
14 repos unable to migrate. Infrastructure needs completeness.

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

### Resource Management

Even while meandering, respect system limits:
- Max 3 parallel subagents (prevent crashes)
- Max 2 parallel Bash commands
- Test each ring before expanding
- Commit checkpoints if the user asks
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

## Validation: Burble v1.0 Test Run (same session)

Applied the methodology to "fix 3 Burble release blockers":

- **Ring 0:** Fixed the 3 blockers (release.yml, OTP rel/, VeriSimDB migrations)
- **Ring 1:** Found 3 more issues in adjacent workflows (placeholder, duplicate SPDX, missing CodeQL language)
- **Ring 2:** Found 4 critical issues (Containerfile paths wrong, port mismatch, health_check function missing, no HTTP health endpoint)
- **Ring 3:** Found 1 broken cross-reference (admin panel.json missing)
- **Total:** 11 fixes from a 3-item task. **4 would have caused production failures.**

### Methodology Refinements (from agent self-critique)

1. **Added hard ceiling at Ring 2** — Ring 3+ only with explicit user permission or when broken references are found in the current repo
2. **"Note, don't action" rule** for cross-project insights — prevents scope creep while preserving the learning
3. **The Surprise Test** — measure methodology value by counting what Ring 1+ found that Ring 0 would have missed
4. **Container validation** added to Ring 2 checklist — "does it serve the right port?" caught a real bug
