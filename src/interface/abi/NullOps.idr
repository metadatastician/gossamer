-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Echo Fibers, Certified Null Operations (CNO), & Observational Null Disclosure (OND)
|||
||| Integrates the proved mathematics from:
|||   * echo-types     (homotopy fibers, slice morphisms, commuting squares, residues)
|||   * absolute-zero  (Pillar 1: Certified Null Operations CNO;
|||                     Pillar 2: Observational Null Disclosure OND;
|||                     EchoBridgeCNO: CNO -> Echo fiber bridge)
|||
||| Applied to Gossamer's runtime security kernel:
|||   1. Rejected operations under `Locked`/`ReadOnly` GuardMode are CNOs on
|||      window state (`lockedGuardIsCNO`).
|||   2. Revoking an already-revoked or unknown capability token is a CNO on
|||      the revocation registry (`revokeInactiveIsCNO`), preventing ring-buffer
|||      poisoning (`src/interface/ffi/src/main.zig`).
|||   3. `OND-3` (`CNO ⊥ OND`): An early-exit capability check that leaves host
|||      state untouched (`IsCNO`) still leaks secret token bits via timing
|||      (`leakyCnoNotOndTime`), whereas constant-time capability checking
|||      satisfies both `IsCNO` and `isOND obsAll` (`ctCapCheckIsOND`).
|||
||| Zero believe_me, zero postulate, zero assert_total. %default total.

module Gossamer.ABI.NullOps

import Data.Nat
import Data.List
import Data.Bits
import Gossamer.ABI.Types
import Gossamer.ABI.WindowStateMachine
import Gossamer.ABI.ResourceAlgebra

%default total

-- Shadow Builtin.trans so `trans Refl q` reduces definitionally on the first
-- argument alone, which `echoMapCompose` uses for pentagon coherence.
%hide Builtin.trans

public export
trans : {0 A : Type} -> {0 x, y, z : A} -> x = y -> y = z -> x = z
trans Refl q = q

public export
transAssoc : {0 A : Type} -> {0 w, x, y, z : A}
          -> (p : w = x) -> (q : x = y) -> (r : y = z)
          -> trans (trans p q) r = trans p (trans q r)
transAssoc Refl _ _ = Refl

--------------------------------------------------------------------------------
-- 1. Echo Types: Homotopy Fibers & Retained Residues (echo-types)
--------------------------------------------------------------------------------

||| A displayed type over `B`.
public export
Displayed : Type -> Type
Displayed b = b -> Type

||| Homotopy fiber of `f : A -> B` over `y : B`.
public export
record Echo {0 A : Type} {0 B : Type} (f : A -> B) (y : B) where
  constructor MkEcho
  echoPre   : A
  echoProof : f echoPre = y

public export
EchoOf : {0 A, B : Type} -> (A -> B) -> Displayed B
EchoOf f = Echo f

||| Every preimage inhabits the fiber at its image.
public export
echoIntro : {0 A, B : Type} -> (f : A -> B) -> (x : A) -> Echo f (f x)
echoIntro _ x = MkEcho x Refl

||| Morphism in the slice category over `B`.
public export
record HomOver {0 A, A', B : Type} (f : A -> B) (f' : A' -> B) where
  constructor MkHomOver
  homMap     : A -> A'
  homCommute : (x : A) -> f' (homMap x) = f x

public export
idHomOver : {0 A, B : Type} -> (f : A -> B) -> HomOver f f
idHomOver _ = MkHomOver (\x => x) (\_ => Refl)

public export
compHomOver :
     {0 A, A', A'', B : Type}
  -> {0 f : A -> B} -> {0 f' : A' -> B} -> {0 f'' : A'' -> B}
  -> HomOver f' f''
  -> HomOver f f'
  -> HomOver f f''
compHomOver k h = MkHomOver
  (\x => k.homMap (h.homMap x))
  (\x => trans (k.homCommute (h.homMap x)) (h.homCommute x))

public export
echoMap :
     {0 A, A', B : Type}
  -> {0 f : A -> B} -> {0 f' : A' -> B}
  -> HomOver f f'
  -> {0 y : B}
  -> Echo f y
  -> Echo f' y
echoMap h (MkEcho x p) = MkEcho (h.homMap x) (trans (h.homCommute x) p)

public export
echoMapId :
     {0 A, B : Type}
  -> {0 f : A -> B}
  -> {0 y : B}
  -> (e : Echo f y)
  -> echoMap (idHomOver f) e = e
echoMapId (MkEcho _ _) = Refl

public export
echoMapCompose :
     {0 A, A', A'', B : Type}
  -> {0 f : A -> B} -> {0 f' : A' -> B} -> {0 f'' : A'' -> B}
  -> (k : HomOver f' f'')
  -> (h : HomOver f f')
  -> {0 y : B}
  -> (e : Echo f y)
  -> echoMap (compHomOver k h) e = echoMap k (echoMap h e)
echoMapCompose k h (MkEcho x p) =
  cong (MkEcho (k.homMap (h.homMap x)))
       (transAssoc (k.homCommute (h.homMap x)) (h.homCommute x) p)

||| Cartesian lift across a commuting square (boundary-crossing transport).
public export
echoMapSquare :
     {0 A, A', B, B' : Type}
  -> {0 f : A -> B} -> {0 f' : A' -> B'}
  -> (u : A -> A')
  -> (v : B -> B')
  -> (sq : (x : A) -> f' (u x) = v (f x))
  -> {0 y : B}
  -> Echo f y
  -> Echo f' (v y)
echoMapSquare u v sq (MkEcho x p) =
  MkEcho (u x) (trans (sq x) (cong v p))

||| Retained residue of an irreversible relegation (`EchoR`).
public export
record EchoR {0 b : Type} (c : Type) (certRel : c -> b -> Type) (y : b) where
  constructor MkEchoR
  residue : c
  cert    : certRel residue y

public export
echoToResidue :
     {0 a, b : Type} -> {0 c : Type} -> {0 certRel : c -> b -> Type}
  -> (f : a -> b)
  -> (kappa : a -> c)
  -> (sound : (x : a) -> certRel (kappa x) (f x))
  -> {0 y : b}
  -> Echo f y -> EchoR c certRel y
echoToResidue f kappa sound (MkEcho x Refl) =
  MkEchoR (kappa x) (sound x)

--------------------------------------------------------------------------------
-- 2. Pillar 1 of Absolute Zero: Certified Null Operations (CNO) & Echo Bridge
--------------------------------------------------------------------------------

||| A state transformer `step : stType -> stType` is a Certified Null Operation (`IsCNO`)
||| when it preserves every state identically (`CNO.agda`).
public export
IsCNO : {stType : Type} -> (stType -> stType) -> Type
IsCNO {stType} step = (st : stType) -> step st = st

||| The identity operation is a CNO (`halt-is-cno` / `empty-is-cno`).
public export
idIsCNO : {stType : Type} -> IsCNO {stType} (\x => x)
idIsCNO _ = Refl

||| Sequential composition of two CNOs is a CNO (`cno-composition`).
public export
cnoCompose : {stType : Type} -> {f, g : stType -> stType} ->
             IsCNO f -> IsCNO g -> IsCNO (\x => g (f x))
cnoCompose cnoF cnoG st = trans (cong g (cnoF st)) (cnoG st)

||| `EchoBridgeCNO` (`echo-from-cno-program-≡`): Every CNO operation `step`
||| inhabits its own `Echo step st` homotopy fiber at every state `st` with
||| `st` itself as the canonical preimage.
public export
cnoEchoFiber : {stType : Type} -> (step : stType -> stType) -> IsCNO step ->
               (st : stType) -> Echo step st
cnoEchoFiber step cno st = MkEcho st (cno st)

--------------------------------------------------------------------------------
-- 3. Gossamer CNO Applications: Guard Enforcement & Revocation Ring Protection
--------------------------------------------------------------------------------

||| Guard-gated window mutation: applies `mutate` only in `Free` mode;
||| in `Locked` or `ReadOnly` mode the window state is untouched.
public export
evalGuardedWindowOp : GuardMode -> (WindowState -> WindowState) -> WindowState -> WindowState
evalGuardedWindowOp Free     mutate st = mutate st
evalGuardedWindowOp Locked   _      st = st
evalGuardedWindowOp ReadOnly _      st = st

||| Theorem: Under `Locked` guard mode, every guarded operation is a CNO.
public export
lockedGuardIsCNO : (mutate : WindowState -> WindowState) ->
                   IsCNO (evalGuardedWindowOp Locked mutate)
lockedGuardIsCNO _ _ = Refl

||| Theorem: Under `ReadOnly` guard mode, every guarded operation is a CNO.
public export
readOnlyGuardIsCNO : (mutate : WindowState -> WindowState) ->
                     IsCNO (evalGuardedWindowOp ReadOnly mutate)
readOnlyGuardIsCNO _ _ = Refl

||| Model of Gossamer's capability revocation state (`main.zig`):
||| `activeTokens` are currently live capability tokens;
||| `revokedRing` is the audit/revocation ring buffer.
public export
record CapRevocationState where
  constructor MkCapRevState
  activeTokens : List Bits64
  revokedRing  : List Bits64

||| Helper dispatching capability revocation on `(isActive, isAlreadyRevoked)`.
public export
applyRevoke : Bool -> Bool -> Bits64 -> CapRevocationState -> CapRevocationState
applyRevoke True  False tok st =
  MkCapRevState (filter (/= tok) st.activeTokens) (tok :: st.revokedRing)
applyRevoke True  True  _   st = st
applyRevoke False _     _   st = st

||| Safe capability revocation: only appends `tok` to `revokedRing` if `tok`
||| was genuinely active (and not already revoked). If `tok` is unknown or
||| already revoked, the operation is a strict CNO — preventing an attacker
||| from flooding the 1024-slot ring buffer with bogus revocations.
public export
safeRevokeCap : Bits64 -> CapRevocationState -> CapRevocationState
safeRevokeCap tok st =
  applyRevoke (elem tok st.activeTokens) (elem tok st.revokedRing) tok st

||| Theorem: Revoking a token that is not active (`elem tok activeTokens = False`)
||| is a Certified Null Operation (`IsCNO`) — the revocation ring buffer is
||| untouched.
public export
revokeInactiveIsCNO : (tok : Bits64) -> (st : CapRevocationState) ->
                      elem tok st.activeTokens = False ->
                      safeRevokeCap tok st = st
revokeInactiveIsCNO tok st notActive =
  cong (\b => applyRevoke b (elem tok st.revokedRing) tok st) notActive

private
applyRevokeAlready : (active : Bool) -> (tok : Bits64) -> (st : CapRevocationState) ->
                     applyRevoke active True tok st = st
applyRevokeAlready True  _ _ = Refl
applyRevokeAlready False _ _ = Refl

||| Theorem: Revoking a token that is already recorded in `revokedRing`
||| (`elem tok revokedRing = True`) is also a Certified Null Operation (`IsCNO`).
public export
revokeAlreadyRevokedIsCNO : (tok : Bits64) -> (st : CapRevocationState) ->
                            elem tok st.revokedRing = True ->
                            safeRevokeCap tok st = st
revokeAlreadyRevokedIsCNO tok st alreadyRevoked =
  trans (cong (\r => applyRevoke (elem tok st.activeTokens) r tok st) alreadyRevoked)
        (applyRevokeAlready (elem tok st.activeTokens) tok st)

--------------------------------------------------------------------------------
-- 4. Pillar 2 of Absolute Zero: Observational Null Disclosure (OND) & OND-3
--------------------------------------------------------------------------------

||| Observable execution outcome: output value and timing/step count (`OND.agda`).
public export
record Exec where
  constructor MkExec
  out  : Nat
  time : Nat

public export
Eq Exec where
  (MkExec o1 t1) == (MkExec o2 t2) = o1 == o2 && t1 == t2

public export
Show Exec where
  show (MkExec o t) = "Exec(out=" ++ show o ++ ", time=" ++ show t ++ ")"

||| An operation over `(secret, public)` inputs with a state-output component
||| and a timing/side-channel component.
public export
record Op where
  constructor MkOp
  stepOut  : (secret : Nat) -> (pub : Nat) -> (stateCell : Nat) -> Nat
  stepTime : (secret : Nat) -> (pub : Nat) -> Nat

||| Run an operation on `(secret, pub)` observing initial output cell `0`.
public export
runOp : Op -> (secret : Nat) -> (pub : Nat) -> Exec
runOp o s p = MkExec (o.stepOut s p 0) (o.stepTime s p)

||| OND-1: An operation `o` satisfies Observational Null Disclosure under
||| observation model `obs` when varying the secret input never alters the
||| observation (`∀ s1 s2 pub, obs (runOp o s1 pub) = obs (runOp o s2 pub)`).
public export
isOND : {obsTy : Type} -> (Exec -> obsTy) -> Op -> Type
isOND obs o = (s1, s2, pub : Nat) -> obs (runOp o s1 pub) = obs (runOp o s2 pub)

public export
obsOut : Exec -> Nat
obsOut e = e.out

public export
obsTime : Exec -> Nat
obsTime e = e.time

public export
obsAll : Exec -> (Nat, Nat)
obsAll e = (e.out, e.time)

||| State-preservation predicate (`OND.is-null`).
public export
isNullOp : Op -> Type
isNullOp o = (s, p, cell : Nat) -> o.stepOut s p cell = cell

||| Witness 1: Constant-time skip (`skip-op`).
public export
skipOp : Op
skipOp = MkOp (\_, _, cell => cell) (\_, _ => 0)

||| Witness 2: Early-exit capability check (`leaky-cno`) — preserves state
||| (`isNullOp`), but its timing depends on the secret token (`stepTime s _ = s`).
public export
leakyCapCheck : Op
leakyCapCheck = MkOp (\_, _, cell => cell) (\s, _ => s)

||| Witness 3: Constant-time capability check (`ct-select` / `ctCapCheck`) —
||| preserves state on denial and always takes constant time `1`.
public export
ctCapCheck : Op
ctCapCheck = MkOp (\_, _, cell => cell) (\_, _ => 1)

||| OND-2: `skipOp` is OND under ANY observation model.
public export
skipIsOND : {obsTy : Type} -> (obs : Exec -> obsTy) -> isOND obs NullOps.skipOp
skipIsOND _ _ _ _ = Refl

||| OND-3a: `leakyCapCheck` is a state CNO (`isNullOp`).
public export
leakyCnoIsNull : isNullOp NullOps.leakyCapCheck
leakyCnoIsNull _ _ _ = Refl

private
zeroNotOne : Not (the Nat 0 = 1)
zeroNotOne Refl impossible

||| OND-3b (`CNO ⊥ OND` independence): Even though `leakyCapCheck` is a state
||| CNO, it violates OND under timing observation (`obsTime`).
public export
leakyCnoNotOndTime : Not (isOND NullOps.obsTime NullOps.leakyCapCheck)
leakyCnoNotOndTime h = zeroNotOne (h 0 1 0)

||| Constant-time capability check (`ctCapCheck`) is both a state CNO and
||| satisfies full `isOND obsAll` (output + timing).
public export
ctCapCheckIsNull : isNullOp NullOps.ctCapCheck
ctCapCheckIsNull _ _ _ = Refl

public export
ctCapCheckIsOND : isOND NullOps.obsAll NullOps.ctCapCheck
ctCapCheckIsOND _ _ _ = Refl
