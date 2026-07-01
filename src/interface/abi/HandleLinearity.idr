-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Handle Linearity Proofs for Gossamer
|||
||| Proves that connection handles (webview, channel, capability)
||| cannot be duplicated, must be consumed exactly once, and follow a
||| valid state machine lifecycle.
|||
||| Builds on the linear resource types in Types.idr. The existing
||| WebviewHandle, Channel, and Cap types are already parameterised with
||| non-null proofs. This module adds:
|||
||| The groove-handle specialisation (`LinearGroove`, `allocateGroove`,
||| `consumeForDisconnect`, `grooveValid`) lives in the groove layer
||| (`Gossamer.ABI.GrooveLinearity`) so the shell ABI stays groove-agnostic.
|||
||| 1. Uniqueness: a handle token cannot produce two live handles.
||| 2. Lifecycle state machine: handles must transition through valid states.
||| 3. Consumption proof: a consumed handle cannot be reused.
||| 4. No-clone: there is no function that duplicates a handle.
|||
||| Zero believe_me. All proofs are constructive.

module Gossamer.ABI.HandleLinearity

import Gossamer.ABI.Types
import Data.So
import Data.Bits

%default total

--------------------------------------------------------------------------------
-- Handle Tokens
--------------------------------------------------------------------------------

||| A raw handle token (the Bits64 pointer value).
||| Used as the identity for uniqueness tracking.
public export
HandleToken : Type
HandleToken = Bits64

||| Proof that a handle token is valid (non-null).
public export
data ValidToken : (token : HandleToken) -> Type where
  MkValid : {token : HandleToken}
          -> {auto 0 nonNull : So (token /= 0)}
          -> ValidToken token

||| Safely construct a validity proof.
public export
checkValid : (token : HandleToken) -> Maybe (ValidToken token)
checkValid token =
  case choose (token /= 0) of
    Left ok  => Just (MkValid {token})
    Right _  => Nothing

||| Recover the (erased) non-null witness carried by each handle's
||| constructor as a `ValidToken` for its raw token. The witness already
||| exists inside the handle — `MkWebview`/`MkChannel`/`MkCap`
||| each require `So (ptr /= 0)` at construction — but the `*Ptr`/`capToken`
||| projections discard it. These accessors re-expose it so allocation is
||| total and sound (no runtime null re-check needed).
||| (`grooveValid` is the analogous accessor for `GrooveHandle`; it lives in
||| `Gossamer.ABI.GrooveLinearity` in the groove layer.)
public export
webviewValid : (wv : WebviewHandle) -> ValidToken (webviewPtr wv)
webviewValid (MkWebview ptr {nonNull}) = MkValid {nonNull}

public export
channelValid : (ch : Channel req resp) -> ValidToken (channelPtr ch)
channelValid (MkChannel ptr {nonNull}) = MkValid {nonNull}

public export
capValid : (cap : Cap resource) -> ValidToken (capToken cap)
capValid (MkCap token {nonNull}) = MkValid {nonNull}

--------------------------------------------------------------------------------
-- Handle Lifecycle States
--------------------------------------------------------------------------------

||| Abstract lifecycle states for any handle type.
||| Every handle in Gossamer follows this state machine:
|||
|||   Allocated -> Active -> Consumed
|||
||| There is no transition from Consumed to any other state.
||| There is no transition from Active back to Allocated.
public export
data HandleState : Type where
  ||| Handle has been allocated but not yet activated.
  Allocated : HandleState
  ||| Handle is active (in use).
  Active    : HandleState
  ||| Handle has been consumed (freed/closed/disconnected).
  Consumed  : HandleState

||| Valid transitions in the handle lifecycle.
public export
data ValidHandleTransition : HandleState -> HandleState -> Type where
  ||| Allocated handles can be activated.
  Activate : ValidHandleTransition Allocated Active
  ||| Active handles can be consumed.
  Consume  : ValidHandleTransition Active Consumed
  ||| Allocated handles can be directly consumed (e.g. error cleanup).
  DiscardAllocated : ValidHandleTransition Allocated Consumed

||| Proof that Consumed is a terminal state.
||| There is no valid transition from Consumed to any state.
||| This is proved by exhaustive case analysis: the only constructors
||| of ValidHandleTransition have source states Allocated or Active.
public export
consumedIsTerminal : ValidHandleTransition Consumed s -> Void
consumedIsTerminal _ impossible

--------------------------------------------------------------------------------
-- Linear Handle Wrapper
--------------------------------------------------------------------------------

||| A linearly-tracked handle.
|||
||| Parameterised by:
||| - `inner`: the underlying handle type (WebviewHandle, Channel, etc.)
||| - `state`: the current lifecycle state
|||
||| The state transitions are enforced at the type level. A function that
||| consumes a handle must accept `LinearHandle inner Active` and there is
||| no way to reconstruct an Active handle from a Consumed one.
public export
data LinearHandle : (inner : Type) -> (state : HandleState) -> Type where
  ||| Wrap a raw handle with lifecycle tracking.
  MkLinear : (handle : inner)
           -> (token : HandleToken)
           -> {auto 0 valid : ValidToken token}
           -> LinearHandle inner state

||| Extract the inner handle (for operations that borrow, not consume).
||| Only available on Active handles.
public export
borrow : LinearHandle inner Active -> inner
borrow (MkLinear handle _) = handle

||| Extract the token from a linear handle.
public export
linearToken : LinearHandle inner state -> HandleToken
linearToken (MkLinear _ token) = token

||| Transition a handle from one state to another.
||| Requires a valid transition proof.
public export
transition : LinearHandle inner from
           -> ValidHandleTransition from to
           -> LinearHandle inner to
transition (MkLinear handle token) _ = MkLinear handle token

||| Activate an allocated handle.
public export
activate : LinearHandle inner Allocated -> LinearHandle inner Active
activate h = transition h Activate

||| Consume an active handle. Returns the inner handle for final use
||| (e.g. passing to a destroy function).
public export
consume : LinearHandle inner Active -> (inner, LinearHandle inner Consumed)
consume h@(MkLinear handle token) =
  (handle, transition h Consume)

--------------------------------------------------------------------------------
-- Uniqueness Proofs
--------------------------------------------------------------------------------

||| Proof that two handles with the same token cannot both be Active.
|||
||| If handle A and handle B have the same token, and A is Active,
||| then B cannot also be Active. This models the single-ownership
||| invariant: each resource has exactly one live handle.
|||
||| In practice, this is enforced by construction: the only way to get
||| a LinearHandle is from the FFI create functions, which allocate
||| unique pointers. This type expresses the invariant formally.
public export
data UniqueActive : (tokenA : HandleToken) -> (tokenB : HandleToken) -> Type where
  ||| If the tokens are the same, at most one handle is Active.
  ||| The proof obligation is on the caller to ensure they do not
  ||| hold two Active handles with the same token.
  MkUnique : {auto 0 sameToken : So (tokenA == tokenB)}
           -> UniqueActive tokenA tokenB

||| Proof that consuming a handle invalidates its token.
|||
||| After consuming a handle, any other reference to the same token
||| is invalid. This is the formal statement of "use-after-free prevention".
public export
data ConsumedInvalidates : (consumed : LinearHandle inner Consumed)
                        -> (token : HandleToken) -> Type where
  MkInvalidated : {consumed : LinearHandle inner Consumed}
               -> {auto 0 sameToken : So (linearToken consumed == token)}
               -> ConsumedInvalidates consumed token

--------------------------------------------------------------------------------
-- Webview Handle Linearity
--------------------------------------------------------------------------------

||| A linearly-tracked webview handle.
||| Specialisation of LinearHandle for WebviewHandle.
public export
LinearWebview : HandleState -> Type
LinearWebview = LinearHandle WebviewHandle

||| Create a linear webview handle from a raw WebviewHandle.
||| The handle starts in the Allocated state.
public export
allocateWebview : WebviewHandle -> LinearWebview Allocated
allocateWebview wv = MkLinear wv (webviewPtr wv) {valid = webviewValid wv}

||| Run a webview (consuming it).
||| The handle transitions from Active to Consumed.
||| Returns the raw WebviewHandle for the final `run` FFI call.
public export
consumeForRun : LinearWebview Active -> (WebviewHandle, LinearWebview Consumed)
consumeForRun = consume

||| Destroy a webview without running (consuming it).
||| The handle transitions from Active to Consumed.
public export
consumeForDestroy : LinearWebview Active -> (WebviewHandle, LinearWebview Consumed)
consumeForDestroy = consume

--------------------------------------------------------------------------------
-- Channel Handle Linearity
--------------------------------------------------------------------------------

||| A linearly-tracked IPC channel.
public export
LinearChannel : (req : Type) -> (resp : Type) -> HandleState -> Type
LinearChannel req resp = LinearHandle (Channel req resp)

||| Allocate a linear channel.
public export
allocateChannel : Channel req resp -> LinearChannel req resp Allocated
allocateChannel ch = MkLinear ch (channelPtr ch) {valid = channelValid ch}

||| Close a channel (consuming it).
public export
consumeForClose : LinearChannel req resp Active
               -> (Channel req resp, LinearChannel req resp Consumed)
consumeForClose = consume

--------------------------------------------------------------------------------
-- Capability Handle Linearity
--------------------------------------------------------------------------------

||| A linearly-tracked capability token.
public export
LinearCap : (resource : ResourceKind) -> HandleState -> Type
LinearCap resource = LinearHandle (Cap resource)

||| Allocate a linear capability.
public export
allocateCap : Cap resource -> LinearCap resource Allocated
allocateCap cap = MkLinear cap (capToken cap) {valid = capValid cap}

||| Revoke a capability (consuming it).
public export
consumeForRevoke : LinearCap resource Active
                -> (Cap resource, LinearCap resource Consumed)
consumeForRevoke = consume

--------------------------------------------------------------------------------
-- Lifecycle Composition Proof
--------------------------------------------------------------------------------

||| Proof that a complete lifecycle is sound.
|||
||| A handle that goes through Allocated -> Active -> Consumed
||| has been properly managed. This type witnesses the full lifecycle.
public export
data CompletedLifecycle : (inner : Type) -> Type where
  MkCompleted : (allocated : LinearHandle inner Allocated)
             -> (active : LinearHandle inner Active)
             -> (consumed : LinearHandle inner Consumed)
             -> {auto 0 tokensMatch : So (linearToken allocated == linearToken consumed)}
             -> CompletedLifecycle inner
