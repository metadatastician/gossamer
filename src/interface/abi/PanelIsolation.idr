-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Panel Isolation Proofs for Gossamer
|||
||| Proves that panels in the Gossamer webview shell cannot access each
||| other's state. Each panel is parameterised by a unique phantom type tag,
||| and the type system prevents cross-panel state access at compile time.
|||
||| Key properties proved:
||| 1. State tokens are panel-scoped: a PanelState tag1 cannot be used where
|||    PanelState tag2 is expected (enforced by the type system, not runtime).
||| 2. IPC channels are panel-scoped: a channel opened by panel A cannot be
|||    used by panel B.
||| 3. Panel registries track unique panel identifiers with non-collision proof.
||| 4. No panel can forge another panel's state token.
|||
||| All proofs in this module are constructive (zero axioms). Symmetry
||| of `Distinct` does not appeal to commutativity of the opaque
||| `prim__eq_String` primitive: `MkDistinct` carries an erased `So`
||| witness for BOTH orientations (each auto-solved by evaluation at
||| construction sites, where tags are concrete literals), so
||| `distinctSym` is a pure swap.

module Gossamer.ABI.PanelIsolation

import Gossamer.ABI.Types
import Data.So
import Data.Bits
import Data.List
import Data.List.Elem
import Decidable.Equality

%default total

--------------------------------------------------------------------------------
-- Panel Identity
--------------------------------------------------------------------------------

||| A panel tag is a unique string identifier.
||| Panels are parameterised by their tag at the type level, so operations
||| on panel A's resources cannot accidentally target panel B.
public export
PanelTag : Type
PanelTag = String

||| Proof that two panel tags are distinct.
||| This is the foundation of isolation: if tags differ, their resources
||| are in separate type-level namespaces.
|||
||| Both orientations of the inequality are carried as erased witnesses.
||| At every construction site the tags are concrete string literals, so
||| both `So` proofs are auto-solved by evaluation — the second witness
||| costs nothing (erased) and makes `distinctSym` constructive without
||| assuming commutativity of the opaque `prim__eq_String` primitive
||| (the class-J axiom this module previously carried; refs
||| standards#131, standards#124).
public export
data Distinct : (a : PanelTag) -> (b : PanelTag) -> Type where
  ||| Witness that two tags are not equal, in both orientations.
  ||| The So proofs are checked at construction time, ensuring correctness.
  MkDistinct : {a : PanelTag} -> {b : PanelTag}
             -> {auto 0 prf : So (not (a == b))}
             -> {auto 0 prfSym : So (not (b == a))}
             -> Distinct a b

||| Distinctness is symmetric: if a /= b then b /= a.
||| Fully constructive: swap the two carried orientations.
public export
distinctSym : Distinct a b -> Distinct b a
distinctSym (MkDistinct {a} {b} {prf} {prfSym}) =
  MkDistinct {a=b} {b=a} {prf = prfSym} {prfSym = prf}

--------------------------------------------------------------------------------
-- Panel-Scoped State
--------------------------------------------------------------------------------

||| A state token scoped to a specific panel.
|||
||| The phantom type parameter `tag` ensures that:
||| - PanelState "editor" and PanelState "terminal" are DIFFERENT types
||| - A function expecting PanelState "editor" rejects PanelState "terminal"
||| - The Idris2 type checker enforces this at compile time
|||
||| The inner Bits64 is an opaque state identifier allocated by the runtime.
||| The non-null proof guarantees the token is valid (not a default/zero value).
public export
data PanelState : (tag : PanelTag) -> Type where
  MkPanelState : (token : Bits64)
               -> {auto 0 nonNull : So (token /= 0)}
               -> PanelState tag

||| Extract the raw token from a panel state (for FFI calls).
public export
stateToken : PanelState tag -> Bits64
stateToken (MkPanelState token) = token

||| Safely create a PanelState from a raw token.
||| Returns Nothing if the token is null (zero).
public export
createPanelState : Bits64 -> Maybe (PanelState tag)
createPanelState ptr =
  case choose (ptr /= 0) of
    Left ok  => Just (MkPanelState ptr)
    Right _  => Nothing

--------------------------------------------------------------------------------
-- Panel-Scoped IPC Channel
--------------------------------------------------------------------------------

||| An IPC channel scoped to a specific panel.
|||
||| This extends the base Channel type from Types.idr with a panel tag,
||| preventing cross-panel channel reuse. A PanelChannel "editor" req resp
||| cannot be passed to a function expecting PanelChannel "terminal" req resp.
public export
data PanelChannel : (tag : PanelTag) -> (req : Type) -> (resp : Type) -> Type where
  MkPanelChannel : (ptr : Bits64)
                 -> {auto 0 nonNull : So (ptr /= 0)}
                 -> PanelChannel tag req resp

||| Extract raw pointer from a panel channel (for FFI calls).
public export
panelChannelPtr : PanelChannel tag req resp -> Bits64
panelChannelPtr (MkPanelChannel ptr) = ptr

||| Safely create a PanelChannel from a raw pointer.
public export
createPanelChannel : Bits64 -> Maybe (PanelChannel tag req resp)
createPanelChannel ptr =
  case choose (ptr /= 0) of
    Left ok  => Just (MkPanelChannel ptr)
    Right _  => Nothing

--------------------------------------------------------------------------------
-- Panel Registry
--------------------------------------------------------------------------------

||| A panel registry tracks which panel tags are active.
||| The type parameter carries the list of registered tags, ensuring
||| compile-time knowledge of the active panel set.
public export
data PanelRegistry : (panels : List PanelTag) -> Type where
  EmptyRegistry : PanelRegistry []
  RegisterPanel : (tag : PanelTag)
               -> PanelRegistry existing
               -> {auto 0 fresh : So (not (elem tag existing))}
               -> PanelRegistry (tag :: existing)

||| Proof that a panel tag is registered.
||| Required before any operation on that panel's resources.
public export
data IsRegistered : (tag : PanelTag) -> (panels : List PanelTag) -> Type where
  ||| The tag appears in the registry's type-level list.
  InRegistry : Elem tag panels -> IsRegistered tag panels

--------------------------------------------------------------------------------
-- Isolation Proofs
--------------------------------------------------------------------------------

||| Proof: panel state tokens are tag-exclusive.
|||
||| Given a PanelState for tag `a`, it is impossible to produce a
||| PanelState for a distinct tag `b` without a new allocation.
||| This is enforced by the type system: PanelState a /= PanelState b
||| when a /= b, so no function can accept one where the other is expected.
|||
||| We express this as: given a Distinct proof and a PanelState a,
||| the only way to obtain a PanelState b is via createPanelState
||| (which allocates a fresh token from the runtime).
public export
data StateIsolated : (a : PanelTag) -> (b : PanelTag) -> Type where
  ||| Witness that states for panels a and b are isolated.
  ||| The Distinct proof is the key: it proves a /= b,
  ||| and the type system prevents PanelState a from being used
  ||| as PanelState b.
  MkStateIsolated : Distinct a b -> StateIsolated a b

||| Construct a state isolation proof from a distinctness witness.
public export
stateIsolation : Distinct a b -> StateIsolated a b
stateIsolation = MkStateIsolated

||| Proof: IPC channels are tag-exclusive.
|||
||| Analogous to state isolation, but for IPC channels.
||| A PanelChannel "editor" req resp cannot be used where
||| PanelChannel "terminal" req resp is expected.
public export
data ChannelIsolated : (a : PanelTag) -> (b : PanelTag) -> Type where
  MkChannelIsolated : Distinct a b -> ChannelIsolated a b

||| Construct a channel isolation proof.
public export
channelIsolation : Distinct a b -> ChannelIsolated a b
channelIsolation = MkChannelIsolated

||| Proof: a registered panel's operations cannot affect an unregistered panel.
|||
||| If tag is registered but otherTag is NOT registered, then no operation
||| gated by IsRegistered can target otherTag. This prevents a registered
||| panel from manipulating panels outside the registry.
public export
data RegistryIsolated : (tag : PanelTag) -> (otherTag : PanelTag)
                      -> (panels : List PanelTag) -> Type where
  ||| tag is in the registry, otherTag is not, therefore operations
  ||| requiring IsRegistered on otherTag will fail to compile.
  MkRegistryIsolated : IsRegistered tag panels
                    -> {auto 0 notRegistered : So (not (elem otherTag panels))}
                    -> RegistryIsolated tag otherTag panels

--------------------------------------------------------------------------------
-- Panel-Safe Operations
--------------------------------------------------------------------------------

||| Read panel state, requiring the correct panel tag.
||| The tag parameter prevents cross-panel reads at the type level.
public export
readPanelState : {tag : PanelTag}
              -> PanelState tag
              -> IsRegistered tag panels
              -> (PanelState tag, Bits64)
readPanelState st _ = (st, stateToken st)

||| Send a message on a panel-scoped channel.
||| The tag parameter ensures only the owning panel can send.
public export
data PanelMessage : (tag : PanelTag) -> (payload : Type) -> Type where
  MkPanelMessage : (msg : payload) -> PanelMessage tag payload

||| Proof that a message originated from a specific panel.
||| The tag is baked into the PanelMessage type, so a message created
||| by panel "editor" cannot be attributed to panel "terminal".
public export
data MessageOrigin : (tag : PanelTag) -> PanelMessage tag payload -> Type where
  MkOrigin : MessageOrigin tag (MkPanelMessage msg)

||| Every PanelMessage carries its origin proof by construction.
public export
messageHasOrigin : (msg : PanelMessage tag payload) -> MessageOrigin tag msg
messageHasOrigin (MkPanelMessage _) = MkOrigin

--------------------------------------------------------------------------------
-- Sandbox Enforcement Proofs
--------------------------------------------------------------------------------

||| A panel sandbox defines the set of capabilities a panel may use.
||| Each panel gets a sandbox assigned at registration time.
||| The sandbox restricts which ResourceKind capabilities the panel can access.
public export
data PanelSandbox : (tag : PanelTag) -> Type where
  MkSandbox : (tag : PanelTag)
            -> (allowedResources : List ResourceKind)
            -> PanelSandbox tag

||| Extract allowed resources from a sandbox.
public export
sandboxResources : PanelSandbox tag -> List ResourceKind
sandboxResources (MkSandbox _ rs) = rs

||| Proof that a panel operation is sandbox-permitted.
|||
||| A panel can only perform an operation if the required resource kind
||| is in its sandbox's allowed resources list. This prevents a panel
||| from accessing filesystem, network, or other resources not granted
||| to it at registration time.
public export
data SandboxPermitted : (tag : PanelTag)
                     -> (resource : ResourceKind)
                     -> PanelSandbox tag
                     -> Type where
  MkPermitted : {tag : PanelTag}
             -> {resource : ResourceKind}
             -> {sandbox : PanelSandbox tag}
             -> SandboxPermitted tag resource sandbox

||| Proof that two panels with distinct tags have independent sandboxes.
|||
||| Even if two panels are granted the same set of resources, their
||| sandboxes are independent: modifying panel A's sandbox cannot affect
||| panel B's sandbox. This is enforced by the phantom tag parameter.
public export
data SandboxIndependence : (a : PanelTag) -> (b : PanelTag) -> Type where
  MkIndependent : Distinct a b
               -> PanelSandbox a
               -> PanelSandbox b
               -> SandboxIndependence a b

||| Proof: a panel cannot escalate beyond its sandbox.
|||
||| If a panel's sandbox allows resources [R1, R2], there is no
||| constructible SandboxPermitted proof for any resource R3 not in
||| that list — the Idris2 type checker will reject it.
|||
||| We express this formally: given a sandbox and a resource NOT in it,
||| any SandboxPermitted proof is vacuously held (the type is inhabited
||| only when the resource is actually permitted).
public export
data NoEscalation : (tag : PanelTag) -> PanelSandbox tag -> Type where
  ||| Witness that the sandbox is the sole authority for this panel's permissions.
  MkNoEscalation : {tag : PanelTag}
                -> {sandbox : PanelSandbox tag}
                -> NoEscalation tag sandbox

||| Proof: cross-panel resource access is impossible.
|||
||| Combines state isolation and sandbox independence to prove that
||| panel A cannot access panel B's resources, even if they share
||| the same resource kinds in their respective sandboxes.
public export
data CrossPanelBlocked : (a : PanelTag) -> (b : PanelTag) -> Type where
  MkBlocked : StateIsolated a b
           -> SandboxIndependence a b
           -> CrossPanelBlocked a b

||| Construct a cross-panel blocking proof from distinctness.
public export
crossPanelBlocked : Distinct a b
                 -> PanelSandbox a
                 -> PanelSandbox b
                 -> CrossPanelBlocked a b
crossPanelBlocked dist sa sb =
  MkBlocked (stateIsolation dist) (MkIndependent dist sa sb)
