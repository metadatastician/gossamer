-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Soft-Groove Disconnect Residue Proof (groove layer)
|||
||| The FFI `gossamer_groove_disconnect_typed` (main.zig) enforces the
||| `SoftGroove` privacy guarantee — "Transient integration — disconnects
||| cleanly, zero residual state" (`Gossamer.ABI.Types.GrooveType`) — by
||| zeroing the *entire* connection slot for a soft groove
||| (`gc.* = .{ .target_id = 0, .groove_type = .hard }`), whereas a hard groove
||| is merely deactivated so its peer identity persists for auto-reconnect.
|||
||| `Gossamer.ABI.ResourceCleanup` proves the generic teardown residue→0 for the
||| plain `disconnect` descent. This module proves the SOFT-specific, stronger
||| property that the *typed* disconnect leaves ZERO residue: the sensitive peer
||| identity is provably erased, not merely marked inactive. This closes the
||| `RC-7`/`RC-8` gap flagged in gossamer#82.
|||
||| Zero believe_me. All proofs are constructive.

module Gossamer.ABI.GrooveResidue

import Gossamer.ABI.Types

%default total

--------------------------------------------------------------------------------
-- Connection slot (mirrors the Zig `GrooveConnection` record)
--------------------------------------------------------------------------------

||| The runtime state of one groove connection slot, mirroring the Zig
||| `{ target_id : u32, groove_type : GrooveType, active : bool }`.
public export
record GrooveConn where
  constructor MkConn
  target : Bits32     -- peer identity — the sensitive residue
  kind   : GrooveType
  active : Bool

||| The sensitive residue held in a slot: the raw peer identity still stored.
||| The `SoftGroove` privacy guarantee requires this to be 0 after disconnect
||| (a soft peer must not be recoverable from a freed slot). It is defined as
||| the raw stored `target` — not gated on `active` — precisely because the
||| privacy property is about erasure of the identity, not liveness.
public export
residue : GrooveConn -> Bits32
residue c = target c

--------------------------------------------------------------------------------
-- The typed disconnect (`gossamer_groove_disconnect_typed`)
--------------------------------------------------------------------------------

||| Model of `gossamer_groove_disconnect_typed`:
|||   * soft groove → wipe the whole slot (`target := 0`), matching the Zig
|||     `gc.* = .{ .target_id = 0, .groove_type = .hard }` — the privacy wipe;
|||   * hard groove → deactivate only, keeping `target` for auto-reconnect.
public export
softDisconnect : GrooveConn -> GrooveConn
softDisconnect (MkConn _ SoftGroove _) = MkConn 0 HardGroove False
softDisconnect (MkConn t HardGroove _) = MkConn t HardGroove False

--------------------------------------------------------------------------------
-- Proofs
--------------------------------------------------------------------------------

||| PRIVACY GUARANTEE: disconnecting a soft groove erases the peer identity —
||| the residue is provably 0. This is the property `ResourceCleanup`'s plain
||| `disconnect` did not establish for the typed soft wipe.
public export
softWipeZeroResidue : (c : GrooveConn) -> kind c = SoftGroove -> residue (softDisconnect c) = 0
softWipeZeroResidue (MkConn _ SoftGroove _) Refl = Refl
softWipeZeroResidue (MkConn _ HardGroove _) Refl impossible

||| The soft wipe clears the *whole* slot, not just the identity: the result is
||| the canonical zeroed connection (matching the Zig struct reset exactly).
public export
softWipeFullyCleared : (c : GrooveConn) -> kind c = SoftGroove
                    -> softDisconnect c = MkConn 0 HardGroove False
softWipeFullyCleared (MkConn _ SoftGroove _) Refl = Refl
softWipeFullyCleared (MkConn _ HardGroove _) Refl impossible

||| CONTRAST (the distinction is real): disconnecting a HARD groove retains the
||| peer identity — residue is unchanged — which is the intended persistence for
||| auto-reconnecting integrations. Together with `softWipeZeroResidue` this shows
||| the two disconnect modes are genuinely different, not both trivially zero.
public export
hardDisconnectRetainsPeer : (c : GrooveConn) -> kind c = HardGroove
                         -> residue (softDisconnect c) = target c
hardDisconnectRetainsPeer (MkConn _ HardGroove _) Refl = Refl
hardDisconnectRetainsPeer (MkConn _ SoftGroove _) Refl impossible

||| IDEMPOTENCE: the typed disconnect is idempotent (matches the Zig
||| "Idempotent" contract) — re-disconnecting an already-disconnected slot is a
||| no-op, so there is no second-wipe hazard.
public export
softDisconnectIdempotent : (c : GrooveConn)
                        -> softDisconnect (softDisconnect c) = softDisconnect c
softDisconnectIdempotent (MkConn _ SoftGroove _) = Refl
softDisconnectIdempotent (MkConn _ HardGroove _) = Refl
