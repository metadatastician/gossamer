-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Epistemic Proof Transport, Information-Flow Lattice, & Residual Evidence
|||
||| Integrates the proved mathematics from three hyperpolymath `-types` repos:
|||   1. epistemic-types         (Warrant, SoundWarrant, ProofTransport across
|||                               trust boundaries, and Fresh/Stale ReadConsistency)
|||   2. secret-types            (confidentiality/integrity flow lattice and
|||                               the 3 minimal TINI census laws)
|||   3. residual-evidence-types (presence without false identification and
|||                               conditional actual-world soundness)
|||
||| Applied to Gossamer's WebView <-> Host FFI boundary:
|||   * Crossing `WebViewGuest => HostFFI` demotes `AsProof` to `AsReceipt`
|||     (`transmit`).
|||   * `opaqueNotCertifying` and `verifyReceiptIsGap` prove that an unverified
|||     IPC receipt cannot be treated as a `Proof` on the host without running
|||     a sound local `Checker HostFFI` (`verify`, `proofSound`).
|||
||| Zero believe_me, zero postulate, zero assert_total. %default total.

module Gossamer.ABI.EpistemicTransport

import Data.Nat
import Data.List
import Data.DPair
import Gossamer.ABI.Types

%default total

--------------------------------------------------------------------------------
-- 1. Standpoints & Epistemic Warrants (epistemic-types Warrant.agda)
--------------------------------------------------------------------------------

||| Trust standpoints in a Gossamer application.
public export
data Standpoint
  = WebViewGuest   -- Untrusted/sandboxed JS frontend inside the webview
  | HostFFI        -- Native Zig/Rust host kernel (`libgossamer`)
  | SandboxPlugin  -- Dynamically loaded native/WASM plugin
  | ExternalPeer   -- External Groove service peer

public export
Eq Standpoint where
  WebViewGuest  == WebViewGuest  = True
  HostFFI       == HostFFI       = True
  SandboxPlugin == SandboxPlugin = True
  ExternalPeer  == ExternalPeer  = True
  _             == _             = False

||| A proof-relevant warrant at standpoint `k` for proposition `a` (`Warrant.agda`).
||| Deliberately carries no `warrantEv -> a` field: warrants are not automatically factive.
public export
record Warrant (k : Standpoint) (0 a : Type) where
  constructor MkWarrant
  warrantEv : Type

||| Standpoint-indexed epistemic claim (`Epi.agda`): packages a warrant with a token.
public export
record Epi (k : Standpoint) (0 a : Type) where
  constructor MkEpi
  warrant  : Warrant k a
  evidence : warrant.warrantEv

||| A sound (factive) warrant adds an explicit soundness map `warrantEv -> a`.
public export
record SoundWarrant (k : Standpoint) (a : Type) where
  constructor MkSoundWarrant
  warrant : Warrant k a
  sound   : warrant.warrantEv -> a

||| Factive reflection (`sound-epi`): only a `SoundWarrant` extracts `a`.
public export
soundEpi : {k : Standpoint} -> {a : Type} ->
           (sw : SoundWarrant k a) -> sw.warrant.warrantEv -> a
soundEpi sw tok = sw.sound tok

--------------------------------------------------------------------------------
-- 2. Proof Transport Across Trust Boundaries (epistemic-types ProofTransport.agda)
--------------------------------------------------------------------------------

||| Verification mode for transported claims (`ProofTransport.Mode`).
public export
data Mode
  = PublicMode
  | Designated Standpoint
  | IssuerMediated
  | EnvMediated
  | OpaqueReceipt

||| Epistemic status of an artifact at a standpoint (`ProofTransport.Status`).
public export
data Status
  = AsData
  | AsCode
  | AsClaimed
  | AsReceipt
  | AsProofUnder Mode
  | AsProof

||| Reasons why upgrading a transported artifact to `AsProof` can fail (`Gap`).
public export
data Gap
  = InvalidEvidence
  | OpaqueGap
  | MissingChecker
  | MissingEvidence

public export
Eq Gap where
  InvalidEvidence == InvalidEvidence = True
  OpaqueGap       == OpaqueGap       = True
  MissingChecker  == MissingChecker  = True
  MissingEvidence == MissingEvidence = True
  _               == _               = False

public export
Show Gap where
  show InvalidEvidence = "InvalidEvidence"
  show OpaqueGap       = "OpaqueGap"
  show MissingChecker  = "MissingChecker"
  show MissingEvidence = "MissingEvidence"

||| Parameterised transport context: artifacts, claims, wire payloads, and
||| holder-indexed semantic meaning.
public export
record TransportSpec where
  constructor MkTransportSpec
  artifact : Type
  claim    : Type
  payload  : artifact -> claim -> Type
  meaning  : Standpoint -> artifact -> claim -> Type

||| Mode-tagged evidence wrapping a wire payload.
public export
data Evidence : (spec : TransportSpec) -> Mode -> spec.artifact -> spec.claim -> Type where
  PublicEv     : {a : spec.artifact} -> {c : spec.claim} ->
                 spec.payload a c -> Evidence spec PublicMode a c
  DesignatedEv : {a : spec.artifact} -> {c : spec.claim} -> (d : Standpoint) ->
                 spec.payload a c -> Evidence spec (Designated d) a c
  IssuerEv     : {a : spec.artifact} -> {c : spec.claim} ->
                 spec.payload a c -> Evidence spec IssuerMediated a c
  EnvEv        : {a : spec.artifact} -> {c : spec.claim} ->
                 spec.payload a c -> Evidence spec EnvMediated a c
  ReceiptEv    : {a : spec.artifact} -> {c : spec.claim} ->
                 spec.payload a c -> Evidence spec OpaqueReceipt a c

public export
evidencePayload : {spec : TransportSpec} -> {m : Mode} ->
                  {a : spec.artifact} -> {c : spec.claim} ->
                  Evidence spec m a c -> spec.payload a c
evidencePayload (PublicEv p)       = p
evidencePayload (DesignatedEv _ p) = p
evidencePayload (IssuerEv p)       = p
evidencePayload (EnvEv p)          = p
evidencePayload (ReceiptEv p)      = p

||| Executable boolean check paired with its soundness proof for `holder`.
public export
record CertificateCheck (spec : TransportSpec) (holder : Standpoint)
                        (a : spec.artifact) (c : spec.claim) where
  constructor MkCertCheck
  check : spec.payload a c -> Bool
  sound : (p : spec.payload a c) -> check p = True -> spec.meaning holder a c

||| Standpoint-scoped checker (`ProofTransport.Checker`).
public export
data Checker : (spec : TransportSpec) -> (holder : Standpoint) ->
               Mode -> spec.artifact -> spec.claim -> Type where
  PublicCheck     : {a : spec.artifact} -> {c : spec.claim} ->
                    CertificateCheck spec holder a c ->
                    Checker spec holder PublicMode a c
  DesignatedCheck : {a : spec.artifact} -> {c : spec.claim} ->
                    CertificateCheck spec holder a c ->
                    Checker spec holder (Designated holder) a c
  IssuerCheck     : {a : spec.artifact} -> {c : spec.claim} ->
                    CertificateCheck spec holder a c ->
                    Checker spec holder IssuerMediated a c
  EnvCheck        : {a : spec.artifact} -> {c : spec.claim} ->
                    CertificateCheck spec holder a c ->
                    Checker spec holder EnvMediated a c
  ReceiptCheck    : {a : spec.artifact} -> {c : spec.claim} ->
                    Checker spec holder OpaqueReceipt a c

||| Predicate witnessing that a mode is certifying (`OpaqueReceipt` is excluded).
public export
data Certifying : Mode -> Type where
  CertPublic     : Certifying PublicMode
  CertDesignated : {d : Standpoint} -> Certifying (Designated d)
  CertIssuer     : Certifying IssuerMediated
  CertEnv        : Certifying EnvMediated

||| Theorem (`opaqueNotCertifying`): An opaque receipt is never certifying.
public export
opaqueNotCertifying : Not (Certifying OpaqueReceipt)
opaqueNotCertifying CertPublic impossible
opaqueNotCertifying CertDesignated impossible
opaqueNotCertifying CertIssuer impossible
opaqueNotCertifying CertEnv impossible

||| Run a checker on mode-matched evidence. `ReceiptCheck` always returns `False`.
public export
runChecker : {spec : TransportSpec} -> {holder : Standpoint} ->
             {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
             Checker spec holder m a c -> Evidence spec m a c -> Bool
runChecker (PublicCheck v)     ev = v.check (evidencePayload ev)
runChecker (DesignatedCheck v) ev = v.check (evidencePayload ev)
runChecker (IssuerCheck v)     ev = v.check (evidencePayload ev)
runChecker (EnvCheck v)        ev = v.check (evidencePayload ev)
runChecker ReceiptCheck        _  = False

||| Soundness of `runChecker` on certifying modes.
public export
checkerSound : {spec : TransportSpec} -> {holder : Standpoint} ->
               {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
               Certifying m ->
               (ck : Checker spec holder m a c) ->
               (ev : Evidence spec m a c) ->
               runChecker ck ev = True ->
               spec.meaning holder a c
checkerSound CertPublic     (PublicCheck v)     ev ok = v.sound (evidencePayload ev) ok
checkerSound CertDesignated (DesignatedCheck v) ev ok = v.sound (evidencePayload ev) ok
checkerSound CertIssuer     (IssuerCheck v)     ev ok = v.sound (evidencePayload ev) ok
checkerSound CertEnv        (EnvCheck v)        ev ok = v.sound (evidencePayload ev) ok

||| Standpoint-indexed view of an artifact (`ProofTransport.View`).
public export
data View : (spec : TransportSpec) -> (holder : Standpoint) ->
            spec.artifact -> Status -> spec.claim -> Type where
  ViewData       : {a : spec.artifact} -> {c : spec.claim} ->
                   View spec holder a AsData c
  ViewCode       : {a : spec.artifact} -> {c : spec.claim} ->
                   View spec holder a AsCode c
  ViewClaimed    : {a : spec.artifact} -> {c : spec.claim} ->
                   View spec holder a AsClaimed c
  ViewReceipt    : {a : spec.artifact} -> {c : spec.claim} ->
                   View spec holder a AsReceipt c
  ViewProofUnder : {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
                   Certifying m ->
                   (ck : Checker spec holder m a c) ->
                   (ev : Evidence spec m a c) ->
                   runChecker ck ev = True ->
                   View spec holder a (AsProofUnder m) c
  ForgetMode     : {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
                   View spec holder a (AsProofUnder m) c ->
                   View spec holder a AsProof c

||| Theorem (`proofSound`): Every `AsProof` view at `holder` entails the
||| semantic meaning `spec.meaning holder a c`. No token-only forgery is possible.
public export
proofSound : {spec : TransportSpec} -> {holder : Standpoint} ->
             {a : spec.artifact} -> {c : spec.claim} ->
             View spec holder a AsProof c -> spec.meaning holder a c
proofSound (ForgetMode (ViewProofUnder cert ck ev ok)) = checkerSound cert ck ev ok

||| Theorem (`proofCannotSupportFalse`): A false claim cannot have an `AsProof` view.
public export
proofCannotSupportFalse : {spec : TransportSpec} -> {holder : Standpoint} ->
                          {a : spec.artifact} -> {c : spec.claim} ->
                          Not (spec.meaning holder a c) ->
                          Not (View spec holder a AsProof c)
proofCannotSupportFalse notMeaning prf = notMeaning (proofSound prf)

||| Trust boundary directed from `from` to `to` (`Boundary`).
public export
record TrustBoundary where
  constructor MkTrustBoundary
  from : Standpoint
  to   : Standpoint

||| Canonical WebView -> Host FFI trust boundary.
public export
webviewToHost : TrustBoundary
webviewToHost = MkTrustBoundary WebViewGuest HostFFI

||| Boundary transmission (`transmit`): crossing a trust boundary demotes
||| `AsProof` at `b.from` to `AsReceipt` at `b.to` (no-smuggling guarantee).
public export
transmit : {spec : TransportSpec} -> {a : spec.artifact} -> {c : spec.claim} ->
           (b : TrustBoundary) ->
           View spec b.from a AsProof c ->
           View spec b.to a AsReceipt c
transmit _ _ = ViewReceipt

decideBool : (b : Bool) -> Either (b = False) (b = True)
decideBool False = Left Refl
decideBool True  = Right Refl

||| Verify certifying evidence with a local checker to upgrade `AsData` to `AsProof`.
public export
verifyCertifying : {spec : TransportSpec} -> {holder : Standpoint} ->
                   {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
                   Certifying m ->
                   (ck : Checker spec holder m a c) ->
                   (ev : Evidence spec m a c) ->
                   Either Gap (View spec holder a AsProof c)
verifyCertifying cert ck ev =
  case decideBool (runChecker ck ev) of
    Right ok => Right (ForgetMode (ViewProofUnder cert ck ev ok))
    Left  _  => Left InvalidEvidence

||| Verify evidence at `holder`. `ReceiptCheck` always fails with `Left OpaqueGap`.
public export
verify : {spec : TransportSpec} -> {holder : Standpoint} ->
         {a : spec.artifact} -> {m : Mode} -> {c : spec.claim} ->
         Checker spec holder m a c ->
         Evidence spec m a c ->
         View spec holder a AsData c ->
         Either Gap (View spec holder a AsProof c)
verify (PublicCheck v)     ev _ = verifyCertifying CertPublic (PublicCheck v) ev
verify (DesignatedCheck v) ev _ = verifyCertifying CertDesignated (DesignatedCheck v) ev
verify (IssuerCheck v)     ev _ = verifyCertifying CertIssuer (IssuerCheck v) ev
verify (EnvCheck v)        ev _ = verifyCertifying CertEnv (EnvCheck v) ev
verify ReceiptCheck        _  _ = Left OpaqueGap

||| Theorem (`verifyReceiptIsGap`): Attempting to verify an `OpaqueReceipt`
||| always returns `Left OpaqueGap`.
public export
verifyReceiptIsGap : {spec : TransportSpec} -> {holder : Standpoint} ->
                     {a : spec.artifact} -> {c : spec.claim} ->
                     (ev : Evidence spec OpaqueReceipt a c) ->
                     (v : View spec holder a AsData c) ->
                     verify {spec} {holder} ReceiptCheck ev v = Left OpaqueGap
verifyReceiptIsGap _ _ = Refl

||| Theorem (`designatedBindsHolder`): A designated checker for `d` at `holder`
||| forces `d = holder`.
public export
designatedBindsHolder : {spec : TransportSpec} -> {holder, d : Standpoint} ->
                        {a : spec.artifact} -> {c : spec.claim} ->
                        Checker spec holder (Designated d) a c -> d = holder
designatedBindsHolder (DesignatedCheck _) = Refl

||| Theorem (`proofHasSuccessfulCheck`): Every `AsProof` view is backed by a
||| certifying checker and evidence whose executable check returned `True`.
public export
proofHasSuccessfulCheck :
     {spec : TransportSpec} -> {holder : Standpoint} ->
     {a : spec.artifact} -> {c : spec.claim} ->
     View spec holder a AsProof c ->
     (m : Mode ** (ck : Checker spec holder m a c ** (ev : Evidence spec m a c **
       runChecker ck ev = True)))
proofHasSuccessfulCheck (ForgetMode (ViewProofUnder {m} _ ck ev ok)) =
  (m ** (ck ** (ev ** ok)))

--------------------------------------------------------------------------------
-- 3. Read-Consistency & Cache Freshness (epistemic-types ReadConsistency / Epistemic.idr)
--------------------------------------------------------------------------------

||| Ground-truth version of a shared configuration/state field.
public export
record FieldVersion where
  constructor MkFieldVersion
  fieldName  : String
  version    : Nat
  lastWriter : Standpoint

||| Staleness witness: known version is strictly older than current version.
public export
data Stale : (reader : Standpoint) -> (field : String) ->
             (knownVer : Nat) -> (currentVer : Nat) -> Type where
  MkStale : LT knownVer currentVer -> Stale reader field knownVer currentVer

||| Freshness witness: pinned to ground-truth `FieldVersion` (`A14` soundness).
public export
data Fresh : (reader : Standpoint) -> (field : String) ->
             (knownVer : Nat) -> (currentVer : Nat) -> Type where
  MkFresh : (fv : FieldVersion) ->
            fv.fieldName = field ->
            fv.version   = currentVer ->
            knownVer     = currentVer ->
            Fresh reader field knownVer currentVer

||| Theorem: A writer always holds fresh knowledge of the version it just wrote.
public export
writerKnowsFresh : (writer : Standpoint) -> (field : String) -> (ver : Nat) ->
                   (fv : FieldVersion) ->
                   fv.fieldName  = field ->
                   fv.version    = ver ->
                   fv.lastWriter = writer ->
                   Fresh writer field ver ver
writerKnowsFresh _ _ _ fv fp vp _ = MkFresh fv fp vp Refl

--------------------------------------------------------------------------------
-- 4. Confidentiality & Integrity Flow Lattice (secret-types Lattice.agda)
--------------------------------------------------------------------------------

||| Three-point security lattice for Gossamer:
||| `PublicLow` (untrusted WebView UI) ⊑ `PluginMid` (sandboxed plugin) ⊑ `HostHigh` (host secrets).
public export
data SecLabel = PublicLow | PluginMid | HostHigh

public export
Eq SecLabel where
  PublicLow == PublicLow = True
  PluginMid == PluginMid = True
  HostHigh  == HostHigh  = True
  _         == _         = False

public export
Show SecLabel where
  show PublicLow = "PublicLow"
  show PluginMid = "PluginMid"
  show HostHigh  = "HostHigh"

||| Permissible information flow `x ⊑ y` (`FlowsTo`).
public export
data FlowsTo : SecLabel -> SecLabel -> Type where
  FlowLowLow   : FlowsTo PublicLow PublicLow
  FlowLowMid   : FlowsTo PublicLow PluginMid
  FlowLowHigh  : FlowsTo PublicLow HostHigh
  FlowMidMid   : FlowsTo PluginMid PluginMid
  FlowMidHigh  : FlowsTo PluginMid HostHigh
  FlowHighHigh : FlowsTo HostHigh  HostHigh

||| Lattice join (`_⊔_`): combining two labels yields the higher confidentiality level.
public export
secJoin : SecLabel -> SecLabel -> SecLabel
secJoin PublicLow y         = y
secJoin PluginMid PublicLow = PluginMid
secJoin PluginMid PluginMid = PluginMid
secJoin PluginMid HostHigh  = HostHigh
secJoin HostHigh  _         = HostHigh

||| Census Law 1 (`⊑-trans`): Information flows compose transitively.
public export
flowsTrans : {x, y, z : SecLabel} -> FlowsTo x y -> FlowsTo y z -> FlowsTo x z
flowsTrans FlowLowLow   q            = q
flowsTrans FlowLowMid   FlowMidMid   = FlowLowMid
flowsTrans FlowLowMid   FlowMidHigh  = FlowLowHigh
flowsTrans FlowLowHigh  FlowHighHigh = FlowLowHigh
flowsTrans FlowMidMid   q            = q
flowsTrans FlowMidHigh  FlowHighHigh = FlowMidHigh
flowsTrans FlowHighHigh FlowHighHigh = FlowHighHigh

||| Census Law 2 (`⊔-upper₁`): Join bounds its left input.
public export
joinUpper1 : (x, y : SecLabel) -> FlowsTo x (secJoin x y)
joinUpper1 PublicLow PublicLow = FlowLowLow
joinUpper1 PublicLow PluginMid = FlowLowMid
joinUpper1 PublicLow HostHigh  = FlowLowHigh
joinUpper1 PluginMid PublicLow = FlowMidMid
joinUpper1 PluginMid PluginMid = FlowMidMid
joinUpper1 PluginMid HostHigh  = FlowMidHigh
joinUpper1 HostHigh  PublicLow = FlowHighHigh
joinUpper1 HostHigh  PluginMid = FlowHighHigh
joinUpper1 HostHigh  HostHigh  = FlowHighHigh

||| Census Law 3 (`⊔-upper₂`): Join bounds its right input.
public export
joinUpper2 : (x, y : SecLabel) -> FlowsTo y (secJoin x y)
joinUpper2 PublicLow PublicLow = FlowLowLow
joinUpper2 PublicLow PluginMid = FlowMidMid
joinUpper2 PublicLow HostHigh  = FlowHighHigh
joinUpper2 PluginMid PublicLow = FlowLowMid
joinUpper2 PluginMid PluginMid = FlowMidMid
joinUpper2 PluginMid HostHigh  = FlowHighHigh
joinUpper2 HostHigh  PublicLow = FlowLowHigh
joinUpper2 HostHigh  PluginMid = FlowMidHigh
joinUpper2 HostHigh  HostHigh  = FlowHighHigh

||| Public-join inversion (`⊔-L₁` & `⊔-L₂`): If `secJoin x y = PublicLow`,
||| then both `x = PublicLow` and `y = PublicLow` (no secret input contributed).
public export
joinLowLeft : {x, y : SecLabel} -> secJoin x y = PublicLow -> x = PublicLow
joinLowLeft {x = PublicLow} _   = Refl
joinLowLeft {x = PluginMid} {y = PublicLow} Refl impossible
joinLowLeft {x = PluginMid} {y = PluginMid} Refl impossible
joinLowLeft {x = PluginMid} {y = HostHigh}  Refl impossible
joinLowLeft {x = HostHigh}  Refl impossible

public export
joinLowRight : {x, y : SecLabel} -> secJoin x y = PublicLow -> y = PublicLow
joinLowRight {x = PublicLow} e = e
joinLowRight {x = PluginMid} {y = PublicLow} _   = Refl
joinLowRight {x = PluginMid} {y = PluginMid} Refl impossible
joinLowRight {x = PluginMid} {y = HostHigh}  Refl impossible
joinLowRight {x = HostHigh}  {y = PublicLow} _   = Refl
joinLowRight {x = HostHigh}  {y = PluginMid} Refl impossible
joinLowRight {x = HostHigh}  {y = HostHigh}  Refl impossible

--------------------------------------------------------------------------------
-- 5. Residual Evidence Diagnostics (residual-evidence-types Core.agda)
--------------------------------------------------------------------------------

||| An inhabited diagnostic case for observation `obs` under evidence `Ev` (`Core.Case`).
public export
record ResidualCase {0 W, O : Type} (observe : W -> O) (Ev : W -> Type) (obs : O) where
  constructor MkResidualCase
  witness     : W
  witnessObs  : observe witness = obs
  witnessEv   : Ev witness

||| A claim `P : W -> Type` holds across a residual case when it holds for EVERY
||| candidate world compatible with `(obs, Ev)` — not merely the witness (`Core.Holds`).
public export
HoldsInCase : {0 W, O : Type} -> (observe : W -> O) -> (Ev : W -> Type) ->
              (obs : O) -> (P : W -> Type) -> Type
HoldsInCase {W} observe Ev obs P =
  (w : W) -> observe w = obs -> Ev w -> P w

||| Theorem (`Core.actual-world-sound`): If `P` holds across the residual case
||| and the actual world satisfies `(observe actual = obs, Ev actual)`, then
||| `P actual` holds conditionally.
public export
actualWorldSound : {0 W, O : Type} -> {observe : W -> O} -> {Ev : W -> Type} ->
                   {obs : O} -> {P : W -> Type} ->
                   HoldsInCase observe Ev obs P ->
                   (actual : W) -> observe actual = obs -> Ev actual -> P actual
actualWorldSound holds actual obsEq ev = holds actual obsEq ev

||| A quantity `qty : W -> Q` is identified by `(observe, Ev, obs)` when all
||| compatible candidate worlds agree on `qty w` (`Core.Identifies`).
public export
Identifies : {0 W, O, Q : Type} -> (observe : W -> O) -> (Ev : W -> Type) ->
             (obs : O) -> (qty : W -> Q) -> (val : Q) -> Type
Identifies {W} observe Ev obs qty val =
  (w : W) -> observe w = obs -> Ev w -> qty w = val

||| Theorem (`Core.different-candidates-refute-identification`):
||| Two compatible candidate worlds `w1, w2` with `qty w1 /= qty w2` refute
||| unique identification of `qty` (presence of a fault does not identify a
||| single subsystem when two candidate worlds produce the same residual).
public export
differentCandidatesRefuteId :
     {0 W, O, Q : Type} -> {observe : W -> O} -> {Ev : W -> Type} ->
     {obs : O} -> {qty : W -> Q} ->
     (w1, w2 : W) ->
     observe w1 = obs -> Ev w1 ->
     observe w2 = obs -> Ev w2 ->
     Not (qty w1 = qty w2) ->
     (val : Q) -> Not (Identifies observe Ev obs qty val)
differentCandidatesRefuteId w1 w2 o1 e1 o2 e2 neq val idPrf =
  neq (trans (idPrf w1 o1 e1) (sym (idPrf w2 o2 e2)))
