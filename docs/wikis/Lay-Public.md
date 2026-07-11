<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Gossamer, in Plain Language

**Build desktop apps that can't leak resources. By design, not by discipline.**

This page explains what Gossamer is for people who don't write software — press, funders, decision-makers, and the simply curious. No technical background needed. If you *are* a developer and want the full picture, start at the [Home](Home) page instead; this is the signpost for everyone else.

---

## The one-sentence version

Gossamer is a tool for building desktop applications in which an entire category of common, costly bugs — programs quietly hogging your computer's memory and other resources until they slow down or crash — is caught and rejected **before the app is ever shipped**, the way a spell-checker underlines a misspelled word before you hit send.

---

## First: what is a "desktop app framework"?

Many programs you use every day — chat apps, note-takers, code editors, music players — are built on a *framework*: a reusable toolkit that handles the universal, repetitive parts (drawing a window, talking to the operating system) so a developer can concentrate on the app itself.

The most popular of these, **Electron**, works by wrapping an ordinary web page inside a desktop window. That trick is why one small team can ship the same app on Windows, macOS, and Linux at once. It is also why some familiar desktop apps feel heavy: each one quietly bundles a complete web browser just to run.

Gossamer does the same job — a web frontend inside a native window — but rebuilds the foundation underneath so that a whole class of bugs simply cannot occur.

---

## The one problem Gossamer solves

Software constantly borrows things from your computer: pieces of memory, open files, network connections, windows, permission to use the camera. Programmers call these **resources**, and every resource that is borrowed must eventually be handed back. When a program forgets — borrowing but never returning — that is a **leak**. Leaks are why an app that ran fine this morning is sluggish by evening, and why "just restart it" is such common advice.

Today, *not* leaking is left to the **discipline** of the programmer: remember to close every file, release every window, tidy up after every task, every single time. Humans forget. The bug ships. Your users find it.

Gossamer moves that responsibility off human memory and onto the **compiler** — the program that translates human-written code into something the machine can run. Gossamer's compiler refuses to translate code that *could* leak. If a resource might not be handed back, the program does not build. The bug never reaches a user because it never leaves the developer's laptop.

> **The analogy.** A spell-checker doesn't ask you to try harder to spell — it flags the mistake before anyone else reads your message. Gossamer is a spell-checker for resource safety. The developer states what should happen ("this window must be closed exactly once"); the compiler holds them to it, automatically, every time.

---

## Why "caught early" matters

The same bug costs wildly different amounts depending on *when* it is found.

| Where the bug is caught | Who pays, and how much |
|---|---|
| On the developer's screen (**Gossamer's approach**) | The developer, in seconds |
| Later, in testing | The team, in hours |
| In production, on a user's machine (the usual case) | The user — then support, then reputation |

"Proven at compile time" means Gossamer pulls these bugs all the way to the cheapest, earliest column. Not caught more often — caught *before shipping is even possible*.

---

## An honest comparison

Gossamer is not claiming to replace battle-tested tools overnight. Here is the fair picture:

| | Electron (today's popular choice) | **Gossamer** |
|---|---|---|
| Size of a minimal app | ~150 MB (bundles a whole browser) | **~1 MB** |
| Resource leaks | Possible; found in production, if at all | **Impossible; rejected at compile time** |
| Permission bypasses | Guarded by config files, which can have typos | **Enforced by the compiler** |
| Maturity | Proven, powers major products | **Alpha research software** |

Electron earns its place: it is everywhere and it works. Gossamer's bet is narrower and deeper — remove one expensive class of bug *by construction*, and do it in a fraction of the footprint.

---

## Who it's for, and where it's used

Gossamer is a component other projects build on, not a consumer app itself. Two real users today:

- **A game desktop shell** — [IDApTIK](https://github.com/hyperpolymath/idaptik), a game, is migrating its desktop wrapper onto Gossamer.
- **A phone app migration** — [neurophone](https://github.com/hyperpolymath/neurophone), an Android app, is moving onto Gossamer's mobile support.

It is a good fit for teams who ship desktop or mobile software where reliability and a small footprint matter more than being able to grab the largest existing ecosystem.

---

## The research behind it

Gossamer's core promise isn't just a design goal — it is **mathematically checked**. The rules that make leaks impossible are written out as formal proofs in a proof assistant called Idris2, which verifies them the way a referee checks every step of a calculation. Those proofs use **zero shortcuts** (no unproven assumptions smuggled in). The work is written up in an academic paper, *Gossamer: A Linearly-Typed Webview Shell with Provable Resource Safety* ([paper source](https://github.com/hyperpolymath/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex)).

---

## Where it honestly stands

Gossamer is **alpha research software**, version 0.3.x, about 92% of the way to its first full milestone, backed by 192 automated tests. It is open source under the MPL-2.0 licence. It is a promising, working prototype with real users beginning to adopt it — not yet a finished product for mission-critical production. We would rather say that plainly than oversell it.

---

## Learn more

| If you want to… | Go to |
|---|---|
| Get the developer overview | [Home](Home) |
| See the full feature comparison | [README.md](https://github.com/hyperpolymath/gossamer/blob/main/README.md) |
| Read the research paper | [gossamer-arxiv-paper.tex](https://github.com/hyperpolymath/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex) |
| Understand the architecture in depth | [docs/README.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/README.adoc) |
| Try building something | [docs/QUICKSTART.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/QUICKSTART.adoc) |
