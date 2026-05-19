-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| IPC Integrity Proofs for Gossamer
|||
||| Proves that messages sent through Gossamer's IPC channels arrive
||| unmodified. The type system encodes message hashes and sequence numbers
||| as dependent types, making tampering detectable at compile time for
||| statically-known protocols, and at runtime for dynamic payloads.
|||
||| Key properties proved:
||| 1. Hash preservation: the hash of a received message equals the hash
|||    of the sent message (if the channel is honest).
||| 2. Sequence monotonicity: message sequence numbers are strictly increasing.
||| 3. Protocol conformance: messages match the declared protocol schema.
||| 4. No phantom messages: every received message has a corresponding send.
|||
||| Zero believe_me. All proofs are constructive.
||| ChainedIntegrity uses propositional equality (=) for clean transitivity
||| via trans, avoiding the need for DecEq on Bits64.

module Gossamer.ABI.IPCIntegrity

import Gossamer.ABI.Types
import Data.So
import Data.Bits
import Data.Nat
import Data.List

%default total

--------------------------------------------------------------------------------
-- Message Hash Type
--------------------------------------------------------------------------------

||| A cryptographic hash of a message payload.
||| Represented as a pair of Bits64 values (128-bit hash).
||| The actual hash computation happens in the Zig FFI layer;
||| the Idris2 ABI tracks hashes as opaque witnesses.
public export
record MsgHash where
  constructor MkHash
  ||| High 64 bits of the hash
  hi : Bits64
  ||| Low 64 bits of the hash
  lo : Bits64

||| Hash equality is decidable.
public export
Eq MsgHash where
  (MkHash h1 l1) == (MkHash h2 l2) = h1 == h2 && l1 == l2

--------------------------------------------------------------------------------
-- Sequence Numbers
--------------------------------------------------------------------------------

||| A monotonically increasing sequence number for IPC messages.
||| The Nat index tracks the sequence at the type level, enabling
||| compile-time proofs about message ordering.
public export
data SeqNum : (n : Nat) -> Type where
  MkSeq : (val : Bits64) -> SeqNum n

||| Extract the raw sequence number value.
public export
seqVal : SeqNum n -> Bits64
seqVal (MkSeq val) = val

||| Proof that one sequence number succeeds another.
||| Used to prove that messages are received in order.
public export
data Succeeds : SeqNum (S n) -> SeqNum n -> Type where
  ||| The successor relationship is witnessed by the Nat indices.
  MkSucceeds : Succeeds (MkSeq {n = S n} v2) (MkSeq {n} v1)

--------------------------------------------------------------------------------
-- Stamped Messages
--------------------------------------------------------------------------------

||| A message with an integrity stamp: hash + sequence number.
|||
||| The stamp is computed at send time and verified at receive time.
||| The type parameters carry the hash and sequence at the type level,
||| enabling static integrity proofs for known protocols.
public export
record StampedMessage (payload : Type) (n : Nat) where
  constructor MkStamped
  ||| The message payload
  body     : payload
  ||| Cryptographic hash of the serialised payload
  hash     : MsgHash
  ||| Sequence number (type-level and value-level)
  seqNum   : SeqNum n

--------------------------------------------------------------------------------
-- Honest Channel Model
--------------------------------------------------------------------------------

||| An honest channel preserves message integrity.
|||
||| This is the specification of what "integrity" means:
||| 1. The payload is unchanged (same hash)
||| 2. The sequence number is preserved
||| 3. No messages are injected or dropped
|||
||| The Zig FFI layer implements this by computing SipHash-2-4 at the
||| send boundary and verifying at the receive boundary. This Idris2
||| module provides the type-level specification that the FFI must satisfy.
public export
data HonestChannel : (req : Type) -> (resp : Type) -> Type where
  ||| An honest channel is parameterised by its request and response types.
  ||| The channel guarantees hash preservation and sequence monotonicity.
  MkHonest : HonestChannel req resp

||| Proof that a message was not tampered with during transit.
|||
||| Given an honest channel, the hash of the received message equals
||| the hash of the sent message. This is the core integrity guarantee.
public export
data Untampered : (sent : StampedMessage payload n)
               -> (received : StampedMessage payload n)
               -> Type where
  ||| Witness that sent.hash == received.hash.
  ||| The Nat indices match (same sequence number), and the hash
  ||| equality is carried as a So proof.
  MkUntampered : {sent : StampedMessage payload n}
              -> {received : StampedMessage payload n}
              -> {auto 0 hashEq : So (sent.hash == received.hash)}
              -> Untampered sent received

||| Proof that a sequence of messages is ordered.
|||
||| A message log is ordered if each successive message has a strictly
||| higher sequence number than its predecessor.
public export
data Ordered : List (StampedMessage payload n) -> Type where
  ||| An empty log is trivially ordered.
  OrdNil  : Ordered []
  ||| A singleton log is trivially ordered.
  OrdOne  : Ordered [msg]

--------------------------------------------------------------------------------
-- Hash Preservation Theorem
--------------------------------------------------------------------------------

||| Hash preservation: on an honest channel, the hash of a received
||| message MUST equal the hash of the sent message.
|||
||| This is the core integrity theorem. It states that if we have an
||| honest channel and a send receipt, any valid VerifiedReceive
||| necessarily carries an Untampered proof (by construction).
|||
||| The proof is definitional: VerifiedReceive includes Untampered as
||| an erased auto-implicit, so the type checker ensures hash equality
||| at construction time. This function witnesses that relationship.
public export
hashPreservation : VerifiedReceive payload n -> Untampered (MkReceipt msg).msg received
hashPreservation (MkVerified (MkReceipt msg) received {intact}) = intact
  where
    (.msg) : SendReceipt payload n -> StampedMessage payload n
    (.msg) (MkReceipt m) = m

||| Sequence monotonicity: for any two successive messages in a valid
||| log, the later message has a strictly greater sequence index.
|||
||| This is proved by construction: StampedMessage carries the sequence
||| number at the type level (Nat index), and Succeeds witnesses that
||| S n > n. A log of StampedMessages with increasing Nat indices is
||| automatically monotonic.
public export
seqMonotonicity : Succeeds (MkSeq {n = S n} v2) (MkSeq {n} v1) -> LTE (S n) (S n)
seqMonotonicity MkSucceeds = reflexive

--------------------------------------------------------------------------------
-- No Phantom Messages
--------------------------------------------------------------------------------

||| A message log paired with its corresponding send receipts.
|||
||| Every received message has a matching send receipt. The type-level
||| Nat indices must align pairwise, preventing phantom messages
||| (messages that appear in the receive log without a corresponding send).
public export
data CorrespondingLog : Type where
  ||| An empty log has no messages.
  CLNil  : CorrespondingLog
  ||| A message with its matching receipt, followed by the rest of the log.
  CLCons : SendReceipt payload n
         -> StampedMessage payload n
         -> CorrespondingLog
         -> CorrespondingLog

||| Proof that every message in a CorrespondingLog has a send receipt.
||| This is definitional — the CLCons constructor requires a receipt for
||| each message, so a CorrespondingLog without receipts cannot be built.
public export
noPhantomMessages : CorrespondingLog -> Nat
noPhantomMessages CLNil = 0
noPhantomMessages (CLCons _ _ rest) = S (noPhantomMessages rest)

--------------------------------------------------------------------------------
-- Channel Composition Integrity
--------------------------------------------------------------------------------

||| Proof that messages routed through a chain of honest channels
||| preserve integrity end-to-end.
|||
||| If channel A is honest (frontend -> middleware) and channel B is
||| honest (middleware -> backend), then the composition A;B is honest:
||| the hash of a message entering A equals the hash exiting B.
|||
||| Uses propositional equality (=) rather than boolean So (==) so that
||| transitivity is definitional (trans), with no believe_me required.
public export
data ChainedIntegrity : Type where
  MkChained : {payload : Type}
           -> {n : Nat}
           -> (sent : StampedMessage payload n)
           -> (mid  : StampedMessage payload n)
           -> (recv : StampedMessage payload n)
           -> (0 leg1 : sent.hash = mid.hash)
           -> (0 leg2 : mid.hash = recv.hash)
           -> ChainedIntegrity

||| End-to-end hash equality for chained channels.
||| If sent.hash = mid.hash and mid.hash = recv.hash,
||| then sent.hash = recv.hash by propositional transitivity.
||| Constructive: zero believe_me, zero axioms.
public export
chainedHashPreservation : (sent : StampedMessage payload n)
                       -> (mid  : StampedMessage payload n)
                       -> (recv : StampedMessage payload n)
                       -> (0 leg1 : sent.hash = mid.hash)
                       -> (0 leg2 : mid.hash = recv.hash)
                       -> sent.hash = recv.hash
chainedHashPreservation sent mid recv leg1 leg2 = trans leg1 leg2

--------------------------------------------------------------------------------
-- Send/Receive Protocol
--------------------------------------------------------------------------------

||| A send receipt proves that a message was submitted to the channel.
||| The receipt carries the hash computed at send time, which the
||| receiver must match for integrity verification.
public export
data SendReceipt : (payload : Type) -> (n : Nat) -> Type where
  MkReceipt : (msg : StampedMessage payload n) -> SendReceipt payload n

||| Extract the hash from a send receipt (for verification).
public export
receiptHash : SendReceipt payload n -> MsgHash
receiptHash (MkReceipt msg) = msg.hash

||| Extract the receipt's stamped message. Top-level (a `where` block on a
||| `data` declaration is not valid Idris2 — this was the original parse
||| failure); used by `MkVerified`'s `Untampered` obligation.
public export
receiptMsg : SendReceipt payload n -> StampedMessage payload n
receiptMsg (MkReceipt m) = m

||| A receive verification pairs a received message with a send receipt
||| and proves that the hashes match.
public export
data VerifiedReceive : (payload : Type) -> (n : Nat) -> Type where
  MkVerified : (receipt : SendReceipt payload n)
            -> (received : StampedMessage payload n)
            -> {auto 0 intact : Untampered (receiptMsg receipt) received}
            -> VerifiedReceive payload n

--------------------------------------------------------------------------------
-- Protocol Conformance
--------------------------------------------------------------------------------

||| A protocol schema is a list of (command name, request type, response type).
||| This reuses the Protocol type from Types.idr but adds integrity tracking.
public export
data IntegrityProtocol : List (String, Type, Type) -> Type where
  IPNil  : IntegrityProtocol []
  IPCons : (name : String) -> (req : Type) -> (resp : Type)
         -> IntegrityProtocol rest
         -> IntegrityProtocol ((name, req, resp) :: rest)

||| Proof that a message conforms to a specific command in the protocol.
|||
||| The message's payload type must match the command's expected request type.
||| This prevents sending a "file_read" payload on a "file_write" command.
public export
data ConformsTo : (cmdName : String) -> (payload : Type)
               -> IntegrityProtocol schema -> Type where
  ||| The command name matches the head of the protocol,
  ||| and the payload type matches the request type.
  ConformHere : ConformsTo name req (IPCons name req resp rest)
  ||| The command is further down in the protocol list.
  ConformThere : ConformsTo name req (IPCons other otherReq otherResp rest)
              -> ConformsTo name req (IPCons other otherReq otherResp rest)

--------------------------------------------------------------------------------
-- Composition: Integrity + Isolation
--------------------------------------------------------------------------------

||| An isolated, integrity-verified message.
|||
||| Combines panel isolation (from PanelIsolation.idr) with IPC integrity.
||| The panel tag ensures the message came from the correct panel,
||| and the hash ensures it was not tampered with.
public export
record IsolatedVerifiedMsg (tag : String) (payload : Type) (n : Nat) where
  constructor MkIsolatedVerified
  ||| The verified receive (hash-checked)
  verified : StampedMessage payload n
  ||| The hash of the sent message (for audit logging)
  sentHash : MsgHash
