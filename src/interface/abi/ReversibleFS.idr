-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Reversible Filesystem Operations, Obliteration Absorption, & Capability Containment
|||
||| Integrates the proved mathematics from:
|||   * januskey   (`verification/proofs/agda/Reversibility.agda` & `JanusKey.ABI.Types`:
|||                 Loss-graded reversible traces, no-hidden-loss theorem,
|||                 obliteration absorption, ValidPath, and transaction state machine)
|||   * typed-wasm (`TypedWasm.ABI.ResourceCapabilities` L15-A..C:
|||                 capability subset containment and call-graph non-laundering)
|||
||| Applied to Gossamer's filesystem (`filesystem.zig`), bundler (`bundler.zig`),
||| config (`conf.zig`), updater (`updater.zig`), and capability kernel (`main.zig`).
|||
||| Zero believe_me, zero postulate, zero assert_total. %default total.

module Gossamer.ABI.ReversibleFS

import Data.Nat
import Data.List
import Data.List.Elem
import Data.So
import Data.String
import Gossamer.ABI.Types
import Gossamer.ABI.ResourceAlgebra

%default total

--------------------------------------------------------------------------------
-- 1. Validated Paths & Traversal-Free Bundler IDs (januskey ValidPath)
--------------------------------------------------------------------------------

||| A validated filesystem path or bundle identifier:
||| 1. Non-empty (`length pathStr > 0`)
||| 2. Free of null bytes (`not (isInfixOf "\0" pathStr)`)
||| 3. Free of parent-directory traversal (`not (isInfixOf ".." pathStr)`)
public export
record ValidPath where
  constructor MkValidPath
  pathStr     : String
  nonEmpty    : So (length pathStr > 0)
  noNulls     : So (not (isInfixOf "\0" pathStr))
  noTraversal : So (not (isInfixOf ".." pathStr))

||| Runtime check constructing a `ValidPath` when all three invariants hold.
public export
validatePath : (s : String) -> Maybe ValidPath
validatePath s with (choose (length s > 0), choose (not (isInfixOf "\0" s)), choose (not (isInfixOf ".." s)))
  _ | (Left ne, Left nn, Left nt) = Just (MkValidPath s ne nn nt)
  _ | _                           = Nothing

--------------------------------------------------------------------------------
-- 2. Loss-Graded Steps, Traces, & Grade-Accounting Theorems (januskey Reversibility.agda)
--------------------------------------------------------------------------------

||| A state-transforming step annotated with a `LossGrade` metadata label
||| (`Finite 0` = lossless grade, `Finite (S k)` = bounded loss grade,
||| `Infinity` = irreversible obliteration grade).
||| Note: `stepGrade` is an algebraic grade annotation on `Step`; constructive
||| state-restoration inverses (`unwrap (wrap st) = st`) are carried by
||| `ReversiblePair` in Section 3 below.
public export
record Step (S : Type) where
  constructor MkStep
  runStep   : S -> S
  stepGrade : LossGrade

||| A trace of steps over state `S`.
public export
Trace : Type -> Type
Trace s = List (Step s)

||| Total loss grade of a trace (`ResourceAlgebra.timelineGrade` instantiated at `LossGrade`).
public export
traceGrade : Trace s -> LossGrade
traceGrade []        = Finite 0
traceGrade (x :: xs) = lossSeq x.stepGrade (traceGrade xs)

||| Execute all steps in a trace sequentially.
public export
runTrace : Trace s -> s -> s
runTrace []        st = st
runTrace (x :: xs) st = runTrace xs (x.runStep st)

||| A step has a lossless grade annotation when `x.stepGrade = Finite 0` (`oneG`).
public export
Lossless : Step s -> Type
Lossless x = x.stepGrade = Finite 0

||| Every step in a trace has a lossless grade annotation (`AllLossless`).
public export
data AllLossless : Trace s -> Type where
  LosslessNil  : AllLossless []
  LosslessCons : {x : Step s} -> {xs : Trace s} ->
                 Lossless x -> AllLossless xs -> AllLossless (x :: xs)

||| Theorem 1 (`all-lossless-trace`): A trace whose steps all have grade `Finite 0`
||| has total trace grade `Finite 0`.
public export
allLosslessTrace : (ts : Trace s) -> AllLossless ts -> traceGrade ts = Finite 0
allLosslessTrace []        LosslessNil          = Refl
allLosslessTrace (x :: xs) (LosslessCons p ps)  =
  trans (cong (\g => lossSeq g (traceGrade xs)) p)
        (trans (lossSeqUnitL (traceGrade xs)) (allLosslessTrace xs ps))

||| Left factor of a zero-loss product must be `Finite 0` (`+g-zero-left`).
public export
lossSeqZeroLeft : (a, b : LossGrade) -> lossSeq a b = Finite 0 -> a = Finite 0
lossSeqZeroLeft (Finite Z)     (Finite _) _    = Refl
lossSeqZeroLeft (Finite (S _)) (Finite _) Refl impossible
lossSeqZeroLeft (Finite _)     Infinity   Refl impossible
lossSeqZeroLeft Infinity       _          Refl impossible

||| Right factor of a zero-loss product must be `Finite 0` (`+g-zero-right`).
public export
lossSeqZeroRight : (a, b : LossGrade) -> lossSeq a b = Finite 0 -> b = Finite 0
lossSeqZeroRight (Finite Z)     (Finite Z)     _    = Refl
lossSeqZeroRight (Finite Z)     (Finite (S _)) Refl impossible
lossSeqZeroRight (Finite (S _)) (Finite _)     Refl impossible
lossSeqZeroRight (Finite _)     Infinity       Refl impossible
lossSeqZeroRight Infinity       _              Refl impossible

||| Theorem 2 (`lossless-trace-all`): A zero-grade trace hides NO nonzero-grade step —
||| if `traceGrade ts = Finite 0`, then EVERY individual step in `ts` has grade `Finite 0`.
public export
losslessTraceAll : (ts : Trace s) -> traceGrade ts = Finite 0 -> AllLossless ts
losslessTraceAll []        _   = LosslessNil
losslessTraceAll (x :: xs) prf =
  LosslessCons
    (lossSeqZeroLeft x.stepGrade (traceGrade xs) prf)
    (losslessTraceAll xs (lossSeqZeroRight x.stepGrade (traceGrade xs) prf))

||| A step is obliterating when its grade is `Infinity` (`zeroG`).
public export
Obliterating : Step s -> Type
Obliterating x = x.stepGrade = Infinity

||| Theorem 3a (`obliterate-absorbs`): Any trace containing an obliterating step
||| has total grade `Infinity`, regardless of what precedes or follows it.
public export
obliterateAbsorbs : {x : Step s} -> (ts : Trace s) ->
                    Obliterating x -> Elem x ts -> traceGrade ts = Infinity
obliterateAbsorbs (x :: xs) ob Here =
  trans (cong (\g => lossSeq g (traceGrade xs)) ob) Refl
obliterateAbsorbs (y :: xs) ob (There later) =
  trans (cong (lossSeq y.stepGrade) (obliterateAbsorbs xs ob later))
        (lossAnnihilR y.stepGrade)

||| Theorem 3b (`obliterated-not-lossless`): No trace containing an obliteration
||| can ever be lossless (`traceGrade ts = Finite 0 -> Void`).
public export
obliteratedNotLossless : {x : Step s} -> (ts : Trace s) ->
                         Obliterating x -> Elem x ts ->
                         Not (traceGrade ts = Finite 0)
obliteratedNotLossless ts ob el prf =
  finiteNotInfinity (trans (sym prf) (obliterateAbsorbs ts ob el))

--------------------------------------------------------------------------------
-- 3. Reversible Pairs & Transaction State Machine (januskey)
--------------------------------------------------------------------------------

||| A certified reversible pair (`ReversiblePair`): `wrap` (execute) and `unwrap`
||| (undo/rollback) with a cancellation proof.
public export
record ReversiblePair (S : Type) where
  constructor MkReversiblePair
  wrap    : S -> S
  unwrap  : S -> S
  cancels : (st : S) -> unwrap (wrap st) = st

public export
wrapStep : ReversiblePair s -> Step s
wrapStep p = MkStep p.wrap (Finite 0)

public export
unwrapStep : ReversiblePair s -> Step s
unwrapStep p = MkStep p.unwrap (Finite 0)

||| Executing `wrap` followed by `unwrap` has trace grade `Finite 0`.
public export
wrapUnwrapGradeZero : (p : ReversiblePair s) ->
                      traceGrade [wrapStep p, unwrapStep p] = Finite 0
wrapUnwrapGradeZero _ = Refl

||| Executing `wrap` followed by `unwrap` restores the exact initial state.
public export
wrapUnwrapId : (p : ReversiblePair s) -> (st : s) ->
               runTrace [wrapStep p, unwrapStep p] st = st
wrapUnwrapId p st = p.cancels st

||| Transaction lifecycle state (`JanusKey.ABI.Types.TxState`).
public export
data TxState = TxPending | TxActive | TxCommitted | TxRolledBack

public export
data TxTransition : TxState -> TxState -> Type where
  TxBegin    : TxTransition TxPending TxActive
  TxCommit   : TxTransition TxActive  TxCommitted
  TxRollback : TxTransition TxActive  TxRolledBack

public export
committedIsTerminal : TxTransition TxCommitted st -> Void
committedIsTerminal _ impossible

public export
rolledBackIsTerminal : TxTransition TxRolledBack st -> Void
rolledBackIsTerminal _ impossible

--------------------------------------------------------------------------------
-- 4. Capability Set Containment & Call-Graph Monotonicity (ResourceCapabilities.idr)
--------------------------------------------------------------------------------

||| Nominal capability identifier for static call-graph checking.
public export
record CapabilityName where
  constructor MkCapabilityName
  capName : String

public export
Eq CapabilityName where
  (MkCapabilityName a) == (MkCapabilityName b) = a == b

public export
Show CapabilityName where
  show (MkCapabilityName n) = n

public export
CapabilitySet : Type
CapabilitySet = List CapabilityName

||| L15-A: A capability set contains no duplicate names.
public export
data DistinctCaps : CapabilitySet -> Type where
  DistinctNil  : DistinctCaps []
  DistinctCons : {c : CapabilityName} -> {rest : CapabilitySet} ->
                 Not (Elem c rest) -> DistinctCaps rest -> DistinctCaps (c :: rest)

||| L15-B: Every capability in `required` is present in `declared`.
public export
data ContainedIn : (required : CapabilitySet) -> (declared : CapabilitySet) -> Type where
  ContainedNil  : ContainedIn [] declared
  ContainedCons : {c : CapabilityName} -> {restReq, declared : CapabilitySet} ->
                  Elem c declared -> ContainedIn restReq declared ->
                  ContainedIn (c :: restReq) declared

public export
containedRefl : (cs : CapabilitySet) -> ContainedIn cs cs
containedRefl []        = ContainedNil
containedRefl (x :: xs) = ContainedCons Here (weaken (containedRefl xs))
  where
    weaken : ContainedIn cs xs -> ContainedIn cs (x :: xs)
    weaken ContainedNil        = ContainedNil
    weaken (ContainedCons h r) = ContainedCons (There h) (weaken r)

public export
elemContained : {c : CapabilityName} -> {ys, zs : CapabilitySet} ->
                Elem c ys -> ContainedIn ys zs -> Elem c zs
elemContained Here      (ContainedCons h _) = h
elemContained (There p) (ContainedCons _ r) = elemContained p r

||| Containment is transitive (`A ⊆ B -> B ⊆ C -> A ⊆ C`): narrowing capabilities
||| monotonically preserves containment in the originally granted budget.
public export
containedTrans : {xs, ys, zs : CapabilitySet} ->
                 ContainedIn xs ys -> ContainedIn ys zs -> ContainedIn xs zs
containedTrans ContainedNil        _   = ContainedNil
containedTrans (ContainedCons h r) byz =
  ContainedCons (elemContained h byz) (containedTrans r byz)

||| L15-C: Call-site compatibility — caller must hold all capabilities callee requires.
public export
data CallCompatible : (caller : CapabilitySet) -> (callee : CapabilitySet) -> Type where
  MkCallCompatible : ContainedIn callee caller -> CallCompatible caller callee

public export
selfCallCompatible : (cs : CapabilitySet) -> CallCompatible cs cs
selfCallCompatible cs = MkCallCompatible (containedRefl cs)

||| Call compatibility composes transitively: no function can launder capabilities
||| through an intermediate helper.
public export
callCompose : {f, g, h : CapabilitySet} ->
              CallCompatible f g -> CallCompatible g h -> CallCompatible f h
callCompose (MkCallCompatible fg) (MkCallCompatible gh) =
  MkCallCompatible (containedTrans gh fg)
