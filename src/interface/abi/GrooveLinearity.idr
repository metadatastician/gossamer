-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Groove Handle Linearity (groove layer)
|||
||| The groove-handle specialisation of the shell's generic linear-handle
||| machinery (`Gossamer.ABI.HandleLinearity`). Relocated here so the shell
||| ABI stays groove-agnostic: the shell proves linearity for *any* handle
||| type via `LinearHandle`, and this module instantiates it for `GrooveHandle`.
|||
||| Proves that a groove connection handle cannot be duplicated, must be
||| consumed exactly once (disconnect), and follows the
||| Allocated -> Active -> Consumed lifecycle — the same guarantees the
||| webview/channel/capability handles enjoy in the shell.
|||
||| Zero believe_me. All proofs are constructive.

module Gossamer.ABI.GrooveLinearity

import Gossamer.ABI.Types
import Gossamer.ABI.HandleLinearity
import Gossamer.ABI.Groove
import Data.So
import Data.Bits

%default total

--------------------------------------------------------------------------------
-- Groove Handle Validity
--------------------------------------------------------------------------------

||| Recover the (erased) non-null witness carried by a `GrooveHandle`'s
||| `MkGroove` constructor as a `ValidToken` for its raw pointer. The groove
||| analogue of `webviewValid`/`channelValid`/`capValid` in
||| `Gossamer.ABI.HandleLinearity`.
public export
grooveValid : (gh : GrooveHandle offers consumes) -> ValidToken (groovePtr gh)
grooveValid (MkGroove ptr {nonNull}) = MkValid {nonNull}

--------------------------------------------------------------------------------
-- Groove Handle Linearity
--------------------------------------------------------------------------------

||| A linearly-tracked groove handle.
||| Specialisation of `LinearHandle` for `GrooveHandle`.
public export
LinearGroove : (offers : CapSet) -> (consumes : CapSet) -> HandleState -> Type
LinearGroove offers consumes = LinearHandle (GrooveHandle offers consumes)

||| Allocate a linear groove handle.
public export
allocateGroove : GrooveHandle offers consumes
              -> LinearGroove offers consumes Allocated
allocateGroove gh = MkLinear gh (groovePtr gh) {valid = grooveValid gh}

||| Disconnect a groove (consuming it).
||| The handle transitions from Active to Consumed.
public export
consumeForDisconnect : LinearGroove offers consumes Active
                    -> (GrooveHandle offers consumes, LinearGroove offers consumes Consumed)
consumeForDisconnect = consume
