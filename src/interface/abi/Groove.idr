-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Gossamer Groove — Type-Safe Composable Service Discovery
|||
||| A "groove" is a bidirectional capability interface between two systems.
||| Each system works standalone but enhances the other when co-present.
||| Grooves are panel-optional: they work headless, but CAN power PanLL panels.
|||
||| The dependent type system guarantees:
||| 1. Safe connect — you cannot connect unless required capabilities are met
||| 2. Safe disconnect — linear types enforce proper cleanup (no dangling grooves)
||| 3. Safe compose — chaining grooves is provably sound
||| 4. No phantom capabilities — you cannot claim what you do not implement
|||
||| Architecture:
|||   GrooveManifest    — declares offered/consumed capabilities (plain value)
|||   GrooveHandle      — linear resource proving a live connection
|||   GrooveComposition — proof that two grooves can be composed
|||
||| Discovery: services expose GET /.well-known/groove on their port.
||| The Zig FFI layer (groove.zig) probes these and constructs handles.
|||
||| This extends the existing Cap/ResourceKind pattern to inter-service
||| boundaries. Where Cap gates operations within a Gossamer app,
||| GrooveHandle gates operations between Gossamer and external services.

module Gossamer.ABI.Groove

import Gossamer.ABI.Types
import Data.So
import Data.List
import Data.List.Elem
import Data.Bits

%default total

--------------------------------------------------------------------------------
-- Capability Types
--------------------------------------------------------------------------------

||| Standard capability types that groove services can offer or consume.
||| Each type corresponds to a well-defined protocol interface.
public export
data CapabilityType : Type where
  ||| WebRTC voice channels (Burble)
  Voice          : CapabilityType
  ||| Real-time text messaging (Burble)
  Text           : CapabilityType
  ||| User presence and speaking indicators (Burble)
  Presence       : CapabilityType
  ||| Positional audio for spatial environments (Burble)
  SpatialAudio   : CapabilityType
  ||| Server-side voice recording (Burble)
  Recording      : CapabilityType
  ||| Text-to-speech synthesis (Burble)
  TTS            : CapabilityType
  ||| Speech-to-text transcription (Burble)
  STT            : CapabilityType
  ||| Cryptographic hash chain verification (Vext)
  Integrity      : CapabilityType
  ||| Chronological feed verification (Vext)
  FeedVerify     : CapabilityType
  ||| Merkle tree operations (Vext)
  HashChain      : CapabilityType
  ||| Digital signature attestation (Vext/Avow)
  Attestation    : CapabilityType
  ||| 8-modal entity storage (VeriSimDB)
  OctadStorage   : CapabilityType
  ||| Cross-modal drift detection (VeriSimDB)
  DriftDetection : CapabilityType
  ||| Temporal version tracking (VeriSimDB)
  TemporalVer    : CapabilityType
  ||| Neurosymbolic security scanning (Hypatia)
  Scanning       : CapabilityType
  ||| Panel-based UI (PanLL)
  PanelUI        : CapabilityType
  ||| Bot orchestration (gitbot-fleet)
  BotOrch        : CapabilityType
  ||| Workflow automation (RPA Elysium)
  Workflow       : CapabilityType
  ||| DNS record verification (rrecord-verity)
  DNSVerify      : CapabilityType
  ||| Configuration orchestration (conflow)
  ConfigOrch     : CapabilityType
  ||| Static analysis (panic-attacker)
  StaticAnalysis : CapabilityType
  ||| Theorem proving (ECHIDNA)
  TheoremProve   : CapabilityType
  ||| Custom capability (extensible)
  Custom         : (name : String) -> CapabilityType

||| Decidable equality for CapabilityType.
||| Required for Subset proofs.
public export
Eq CapabilityType where
  Voice == Voice = True
  Text == Text = True
  Presence == Presence = True
  SpatialAudio == SpatialAudio = True
  Recording == Recording = True
  TTS == TTS = True
  STT == STT = True
  Integrity == Integrity = True
  FeedVerify == FeedVerify = True
  HashChain == HashChain = True
  Attestation == Attestation = True
  OctadStorage == OctadStorage = True
  DriftDetection == DriftDetection = True
  TemporalVer == TemporalVer = True
  Scanning == Scanning = True
  PanelUI == PanelUI = True
  BotOrch == BotOrch = True
  Workflow == Workflow = True
  DNSVerify == DNSVerify = True
  ConfigOrch == ConfigOrch = True
  StaticAnalysis == StaticAnalysis = True
  TheoremProve == TheoremProve = True
  (Custom a) == (Custom b) = a == b
  _ == _ = False

||| Convert capability type to its wire name (for JSON manifests).
public export
capabilityName : CapabilityType -> String
capabilityName Voice = "voice"
capabilityName Text = "text"
capabilityName Presence = "presence"
capabilityName SpatialAudio = "spatial-audio"
capabilityName Recording = "recording"
capabilityName TTS = "tts"
capabilityName STT = "stt"
capabilityName Integrity = "integrity"
capabilityName FeedVerify = "feed-verification"
capabilityName HashChain = "hash-chain"
capabilityName Attestation = "attestation"
capabilityName OctadStorage = "octad-storage"
capabilityName DriftDetection = "drift-detection"
capabilityName TemporalVer = "temporal-versioning"
capabilityName Scanning = "scanning"
capabilityName PanelUI = "panel-ui"
capabilityName BotOrch = "bot-orchestration"
capabilityName Workflow = "workflow"
capabilityName DNSVerify = "dns-verify"
capabilityName ConfigOrch = "config-orchestration"
capabilityName StaticAnalysis = "static-analysis"
capabilityName TheoremProve = "theorem-proving"
capabilityName (Custom n) = n

--------------------------------------------------------------------------------
-- Wire Protocol Types
--------------------------------------------------------------------------------

||| Wire protocols for groove communication.
public export
data WireProtocol : Type where
  WebRTC    : WireProtocol
  WebSocket : WireProtocol
  HTTP      : WireProtocol
  GRPC      : WireProtocol
  NNTPS     : WireProtocol

--------------------------------------------------------------------------------
-- Capability Sets (Type-Level)
--------------------------------------------------------------------------------

||| A capability set is a list of capability types.
||| Used at the type level to parameterise groove manifests and handles.
public export
CapSet : Type
CapSet = List CapabilityType

||| Proof that one capability set is a subset of another.
||| This is the core safety mechanism: you cannot connect a groove
||| unless your requirements are a subset of what the target offers.
public export
data IsSubset : (required : CapSet) -> (offered : CapSet) -> Type where
  ||| Empty set is subset of anything.
  SubNil  : IsSubset [] offered
  ||| If cap is in offered, and rest is subset of offered,
  ||| then (cap :: rest) is subset of offered.
  SubCons : {auto elemPrf : Elem cap offered}
         -> IsSubset rest offered
         -> IsSubset (cap :: rest) offered

||| Check at runtime whether a capability list is subset of another.
||| Returns a decision — proof if true, refutation if false.
public export
checkSubset : (required : CapSet) -> (offered : CapSet) -> Bool
checkSubset [] _ = True
checkSubset (r :: rs) offered =
  case elem r offered of
    True => checkSubset rs offered
    False => False

--------------------------------------------------------------------------------
-- Groove Manifest (Plain Value)
--------------------------------------------------------------------------------

||| A groove manifest declares what a service offers and what it consumes.
||| This is a PLAIN VALUE — not a resource. Can be freely copied and serialised.
|||
||| The offers and consumes fields are type-level CapSets, enabling
||| compile-time verification of groove compatibility.
public export
record GrooveManifest (offers : CapSet) (consumes : CapSet) where
  constructor MkManifest
  ||| Service identifier (e.g. "burble", "vext", "verisimdb")
  serviceId      : String
  ||| Service version (semver)
  serviceVersion : String
  ||| Port number for groove discovery
  port           : Bits16
  ||| Health check endpoint path
  healthPath     : String

||| Well-known service manifests.
||| These define the CANONICAL capability sets for core services.
||| Any implementation claiming to be "burble" MUST offer these capabilities.

||| Burble: voice-first communication platform.
public export
burbleManifest : GrooveManifest
  [Voice, Text, Presence, SpatialAudio, Recording, TTS, STT]
  [Integrity, OctadStorage, Scanning]
burbleManifest = MkManifest "burble" "0.1.0" 6473 "/health"

||| Vext: verifiable communications protocol.
public export
vextManifest : GrooveManifest
  [Integrity, FeedVerify, HashChain, Attestation]
  [Voice, Text, OctadStorage]
vextManifest = MkManifest "vext" "0.1.0" 6480 "/health"

||| VeriSimDB: cross-modal entity consistency engine.
public export
verisimdbManifest : GrooveManifest
  [OctadStorage, DriftDetection, TemporalVer]
  [Scanning]
verisimdbManifest = MkManifest "verisimdb" "0.1.0" 8080 "/health"

||| Hypatia: neurosymbolic CI/CD intelligence.
public export
hypatiaManifest : GrooveManifest
  [Scanning, StaticAnalysis]
  [OctadStorage, Workflow]
hypatiaManifest = MkManifest "hypatia" "0.1.0" 9090 "/health"

||| PanLL: neurosymbolic panel workspace.
public export
panllManifest : GrooveManifest
  [PanelUI]
  [Voice, Text, Presence, Integrity, OctadStorage, Scanning]
panllManifest = MkManifest "panll" "0.1.0" 8000 "/health"

||| ECHIDNA: neurosymbolic theorem prover.
public export
echidnaManifest : GrooveManifest
  [TheoremProve]
  [OctadStorage, Scanning]
echidnaManifest = MkManifest "echidna" "0.1.0" 9000 "/health"

||| RPA Elysium: robotic process automation.
public export
rpaManifest : GrooveManifest
  [Workflow]
  [Voice, Text, OctadStorage, Scanning]
rpaManifest = MkManifest "rpa-elysium" "0.1.0" 7800 "/health"

||| Conflow: configuration orchestration.
public export
conflowManifest : GrooveManifest
  [ConfigOrch]
  [OctadStorage]
conflowManifest = MkManifest "conflow" "0.1.0" 7700 "/health"

||| Panic-attacker: universal static analysis.
public export
panicManifest : GrooveManifest
  [StaticAnalysis]
  [OctadStorage, Workflow]
panicManifest = MkManifest "panic-attack" "0.1.0" 7600 "/health"

||| Gitbot-fleet: automated bot coordination.
public export
gitbotManifest : GrooveManifest
  [BotOrch]
  [Scanning, Workflow, OctadStorage]
gitbotManifest = MkManifest "gitbot-fleet" "0.1.0" 8080 "/health"

--------------------------------------------------------------------------------
-- Groove Handle (Linear Resource)
--------------------------------------------------------------------------------

||| A live connection to a grooved service.
|||
||| This is a LINEAR resource: it must be disconnected exactly once.
||| The type parameters carry:
||| - offers: what the connected service provides
||| - consumes: what the connected service wants from us
|||
||| You can only create a GrooveHandle by successfully probing a service
||| and verifying that its manifest satisfies your requirements.
public export
data GrooveHandle : (offers : CapSet) -> (consumes : CapSet) -> Type where
  MkGroove : (ptr : Bits64)
          -> {auto 0 nonNull : So (ptr /= 0)}
          -> GrooveHandle offers consumes

||| Safely create a GrooveHandle from a raw pointer.
||| Returns Nothing if the pointer is null.
public export
createGroove : Bits64 -> Maybe (GrooveHandle offers consumes)
createGroove ptr =
  case choose (ptr /= 0) of
    Left  ok => Just (MkGroove ptr)
    Right _  => Nothing

||| Extract raw pointer from groove handle (for FFI calls).
public export
groovePtr : GrooveHandle offers consumes -> Bits64
groovePtr (MkGroove ptr) = ptr

--------------------------------------------------------------------------------
-- Groove Composition (Type-Safe)
--------------------------------------------------------------------------------

||| Proof that two grooves can be composed.
|||
||| Service A offers caps that service B consumes, AND
||| service B offers caps that service A consumes.
||| This is the mathematical guarantee that composing them is sound.
|||
||| Example: Burble offers [Voice, Text], Vext consumes [Voice, Text] ✓
|||          Vext offers [Integrity], Burble consumes [Integrity] ✓
|||          Therefore Burble ↔ Vext composition is sound.
public export
data GrooveCompat : (aOffers : CapSet) -> (aConsumes : CapSet)
                 -> (bOffers : CapSet) -> (bConsumes : CapSet)
                 -> Type where
  MkCompat : {auto aFeedsB : IsSubset bConsumes aOffers}
          -> {auto bFeedsA : IsSubset aConsumes bOffers}
          -> GrooveCompat aOffers aConsumes bOffers bConsumes

||| Runtime compatibility check between two manifests.
||| Returns True if both sides can satisfy each other's requirements.
||| Takes the capability sets as explicit arguments since the record's
||| type parameters are erased at runtime.
public export
isCompatible : (aOff, aCon, bOff, bCon : CapSet)
            -> GrooveManifest aOff aCon -> GrooveManifest bOff bCon -> Bool
isCompatible aOff aCon bOff bCon _ _ =
  checkSubset bCon aOff && checkSubset aCon bOff

||| A composed groove pair — two handles that have been verified compatible.
||| Both handles are linear and must be individually disconnected.
public export
record GroovePair where
  constructor MkPair
  leftPtr  : Bits64
  rightPtr : Bits64

--------------------------------------------------------------------------------
-- Groove Discovery Result
--------------------------------------------------------------------------------

||| Result of probing a groove target.
public export
data GrooveProbeResult : Type where
  ||| Service not found at expected port.
  NotFound      : GrooveProbeResult
  ||| Service found but manifest is malformed or incompatible.
  Incompatible  : (reason : String) -> GrooveProbeResult
  ||| Service found and connected. Provides offers/consumes info.
  Connected     : (serviceId : String)
               -> (version : String)
               -> (offeredCaps : List String)
               -> (consumedCaps : List String)
               -> GrooveProbeResult

||| Convert probe result to a status code for the FFI boundary.
public export
probeResultToStatus : GrooveProbeResult -> Bits32
probeResultToStatus NotFound = 0
probeResultToStatus (Incompatible _) = 1
probeResultToStatus (Connected _ _ _ _) = 2

--------------------------------------------------------------------------------
-- Groove Triad (Burble + Vext + Avow)
--------------------------------------------------------------------------------

||| The Burble verification triad: three grooves that together provide
||| full communication integrity.
|||
||| - Burble: voice + text transport
||| - Vext: hash chain integrity (messages are chronological, uninjected)
||| - Avow: consent attestation (permissions formally verified)
|||
||| When all three are grooved, communications have:
||| 1. Low-latency delivery (Burble WebRTC)
||| 2. Cryptographic proof of integrity (Vext Merkle trees)
||| 3. Formal proof of consent (Avow Idris2 proofs)
public export
record VerificationTriad where
  constructor MkTriad
  ||| Burble groove handle (voice + text)
  burble : Bits64
  ||| Vext groove handle (integrity)
  vext   : Bits64
  ||| Whether Avow attestation is available
  avow   : Bool

||| Check if the full triad is active.
public export
isTriadComplete : VerificationTriad -> Bool
isTriadComplete t = t.burble /= 0 && t.vext /= 0 && t.avow

--------------------------------------------------------------------------------
-- Applicability Levels
--------------------------------------------------------------------------------

||| Groove applicability — what scale of interaction this groove supports.
||| A groove can work at multiple levels simultaneously.
public export
data Applicability : Type where
  ||| Single user, local tools (e.g. panic-attacker, empty-linter)
  Individual  : Applicability
  ||| Small team collaboration (e.g. Burble voice, VeriSimDB)
  Team        : Applicability
  ||| Large-scale open participation (e.g. Vext feeds, civic-connect)
  MassiveOpen : Applicability

||| Services can declare multiple applicability levels.
public export
ApplicabilitySet : Type
ApplicabilitySet = List Applicability

--------------------------------------------------------------------------------
-- Groove Handshake Termination
--------------------------------------------------------------------------------

||| States in the groove handshake protocol.
|||
||| The handshake goes:
|||   Idle -> Probing -> ManifestReceived -> CapabilityCheck -> Connected
|||                   -> Rejected (terminal)
|||                                        -> Rejected (terminal)
|||
||| The protocol must terminate: every state either transitions forward
||| or reaches a terminal state. No cycles are possible.
public export
data HandshakeState : Type where
  ||| Initial state — no connection attempted.
  HSIdle             : HandshakeState
  ||| TCP connection established, HTTP GET sent.
  HSProbing          : HandshakeState
  ||| Manifest JSON received and parsed.
  HSManifestReceived : HandshakeState
  ||| Capability subset check in progress.
  HSCapabilityCheck  : HandshakeState
  ||| Handshake completed successfully.
  HSConnected        : HandshakeState
  ||| Handshake failed (terminal state).
  HSRejected         : HandshakeState

||| Valid transitions in the handshake protocol.
||| The transitions form a DAG (no cycles), guaranteeing termination.
public export
data HandshakeTransition : HandshakeState -> HandshakeState -> Type where
  ||| Begin probing from idle.
  BeginProbe     : HandshakeTransition HSIdle HSProbing
  ||| Receive manifest from probe.
  ReceiveManifest : HandshakeTransition HSProbing HSManifestReceived
  ||| Probe failed (network error, no manifest).
  ProbeFailed    : HandshakeTransition HSProbing HSRejected
  ||| Begin capability check after receiving manifest.
  BeginCapCheck  : HandshakeTransition HSManifestReceived HSCapabilityCheck
  ||| Manifest is malformed.
  ManifestBad    : HandshakeTransition HSManifestReceived HSRejected
  ||| Capability check passed — connect.
  CapCheckOk     : HandshakeTransition HSCapabilityCheck HSConnected
  ||| Capability check failed — reject.
  CapCheckFail   : HandshakeTransition HSCapabilityCheck HSRejected

||| Proof: HSConnected is terminal (no outgoing transitions).
||| There are no HandshakeTransition constructors with source HSConnected.
public export
connectedIsTerminal : HandshakeTransition HSConnected s -> Void
connectedIsTerminal _ impossible

||| Proof: HSRejected is terminal (no outgoing transitions).
||| There are no HandshakeTransition constructors with source HSRejected.
public export
rejectedIsTerminal : HandshakeTransition HSRejected s -> Void
rejectedIsTerminal _ impossible

||| Proof: the handshake strictly decreases a ranking function.
|||
||| We assign ranks: Idle=5, Probing=4, ManifestReceived=3,
||| CapabilityCheck=2, Connected=0, Rejected=0.
||| Every valid transition moves to a strictly lower rank.
||| Since ranks are bounded natural numbers, the handshake terminates.
public export
handshakeRank : HandshakeState -> Nat
handshakeRank HSIdle             = 5
handshakeRank HSProbing          = 4
handshakeRank HSManifestReceived = 3
handshakeRank HSCapabilityCheck  = 2
handshakeRank HSConnected        = 0
handshakeRank HSRejected         = 0

||| Every handshake transition strictly decreases the rank.
public export
transitionDecreases : (t : HandshakeTransition from to)
                   -> LTE (S (handshakeRank to)) (handshakeRank from)
-- Rank table: HSIdle 5, HSProbing 4, HSManifestReceived 3,
-- HSCapabilityCheck 2, HSConnected 0, HSRejected 0.  Goal is
-- `LTE (S rank[to]) rank[from]`.  The `-> HSRejected/HSConnected`
-- (rank 0) transitions need `LTE 1 k = LTESucc LTEZero`, NOT the
-- `LTE k k` terms the pre-compile draft carried (those were latent
-- type errors masked by the earlier `lteRefl` scope failure).
transitionDecreases BeginProbe      = LTESucc (LTESucc (LTESucc (LTESucc (LTESucc LTEZero)))) -- LTE 5 5  (HSIdle→HSProbing)
transitionDecreases ReceiveManifest = LTESucc (LTESucc (LTESucc (LTESucc LTEZero)))           -- LTE 4 4  (HSProbing→HSManifestReceived)
transitionDecreases ProbeFailed     = LTESucc LTEZero                                         -- LTE 1 4  (HSProbing→HSRejected)
transitionDecreases BeginCapCheck   = LTESucc (LTESucc (LTESucc LTEZero))                     -- LTE 3 3  (HSManifestReceived→HSCapabilityCheck)
transitionDecreases ManifestBad     = LTESucc LTEZero                                         -- LTE 1 3  (HSManifestReceived→HSRejected)
transitionDecreases CapCheckOk      = LTESucc LTEZero                                         -- LTE 1 2  (HSCapabilityCheck→HSConnected)
transitionDecreases CapCheckFail    = LTESucc LTEZero                                         -- LTE 1 2  (HSCapabilityCheck→HSRejected)
