-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Memory Layout Proofs for Gossamer
|||
||| Provides formal proofs about memory layout, alignment, and padding
||| for Gossamer's C-compatible types. Ensures the Idris2 ABI definitions
||| match the Zig FFI implementation at the byte level.
|||
||| Key types verified:
||| - GossamerHandle: opaque, pointer-sized
||| - ChannelHandle: opaque, pointer-sized
||| - WindowConfig: packed struct layout
||| - Result enum: C int (4 bytes)

module Gossamer.ABI.Layout

import Gossamer.ABI.Types
import Data.Vect
import Data.So

%default total

--------------------------------------------------------------------------------
-- Alignment Utilities
--------------------------------------------------------------------------------

||| Calculate padding needed to reach the next aligned offset.
public export
paddingFor : (offset : Nat) -> (alignment : Nat) -> Nat
paddingFor offset alignment =
  if offset `mod` alignment == 0
    then 0
    else alignment - (offset `mod` alignment)

||| Align an offset up to the given alignment boundary.
public export
alignUp : (offset : Nat) -> (alignment : Nat) -> Nat
alignUp offset alignment = offset + paddingFor offset alignment

--------------------------------------------------------------------------------
-- Struct Field Layout
--------------------------------------------------------------------------------

||| A field in a C struct: name, size, and alignment.
public export
record FieldSpec where
  constructor MkFieldSpec
  fieldName  : String
  fieldSize  : Nat
  fieldAlign : Nat

||| Calculate the offset of each field in a packed struct.
||| Returns a list of (field name, offset, size) triples.
public export
layoutFields : (startOffset : Nat) -> List FieldSpec -> List (String, Nat, Nat)
layoutFields _ [] = []
layoutFields offset (f :: fs) =
  let aligned = alignUp offset f.fieldAlign
  in (f.fieldName, aligned, f.fieldSize) :: layoutFields (aligned + f.fieldSize) fs

||| Total size of a struct including final padding for alignment.
public export
structSize : (structAlign : Nat) -> List FieldSpec -> Nat
structSize sAlign fields = alignUp (go 0 fields) sAlign
  where
    go : Nat -> List FieldSpec -> Nat
    go offset [] = offset
    go offset (f :: fs) =
      let aligned = alignUp offset f.fieldAlign
      in go (aligned + f.fieldSize) fs

--------------------------------------------------------------------------------
-- Proof: Opaque Handle Types
--------------------------------------------------------------------------------

||| All opaque handles are pointer-sized.
||| On 64-bit platforms, this is 8 bytes. On WASM, 4 bytes.
public export
handleSize : (p : Platform) -> Nat
handleSize WASM = 4
handleSize _    = 8

||| Proof that WebviewHandle is pointer-sized on the current platform.
public export
webviewHandleSize : HasSize WebviewHandle (handleSize thisPlatform)
webviewHandleSize = SizeProof

||| Proof that WebviewHandle has pointer alignment.
public export
webviewHandleAlign : HasAlignment WebviewHandle (handleSize thisPlatform)
webviewHandleAlign = AlignProof

||| Proof that Channel handles are pointer-sized.
public export
channelHandleSize : HasSize (Channel req resp) (handleSize thisPlatform)
channelHandleSize = SizeProof

||| Proof that Cap tokens are pointer-sized (Bits64 token ID).
public export
capTokenSize : HasSize (Cap resource) 8
capTokenSize = SizeProof

--------------------------------------------------------------------------------
-- Proof: Result Enum
--------------------------------------------------------------------------------

||| Result is represented as a C int (4 bytes on all platforms).
public export
resultSize : HasSize Result 4
resultSize = SizeProof

||| Result has 4-byte alignment (matching C int).
public export
resultAlign : HasAlignment Result 4
resultAlign = AlignProof

||| All result code values fit in a Bits32.
||| (Max value is 10 = CapabilityDenied, well within 0..4294967295)
public export
resultFitsInBits32 : (r : Result) -> So (resultToInt r <= 4294967295)
resultFitsInBits32 Ok = Oh
resultFitsInBits32 Error = Oh
resultFitsInBits32 InvalidParam = Oh
resultFitsInBits32 OutOfMemory = Oh
resultFitsInBits32 NullPointer = Oh
resultFitsInBits32 AlreadyConsumed = Oh
resultFitsInBits32 ResourceLeaked = Oh
resultFitsInBits32 DoubleFree = Oh
resultFitsInBits32 WebviewUnavailable = Oh
resultFitsInBits32 IPCProtocolError = Oh
resultFitsInBits32 CapabilityDenied = Oh

--------------------------------------------------------------------------------
-- Proof: WindowConfig Layout
--------------------------------------------------------------------------------

||| WindowConfig field specifications for C ABI layout calculation.
||| Fields: title (ptr), width (u32), height (u32), resizable (bool/u8),
|||          decorations (bool/u8), fullscreen (bool/u8)
|||
||| Note: In the FFI, title is passed as a C string pointer, not embedded
||| in the struct. The struct layout here is for documentation and
||| verification purposes.
public export
windowConfigFields : List FieldSpec
windowConfigFields =
  [ MkFieldSpec "title_ptr"   8 8   -- Pointer to title string
  , MkFieldSpec "width"       4 4   -- Bits32
  , MkFieldSpec "height"      4 4   -- Bits32
  , MkFieldSpec "resizable"   4 4   -- Bits32 (bool as C int for alignment)
  , MkFieldSpec "decorations" 4 4   -- Bits32
  , MkFieldSpec "fullscreen"  4 4   -- Bits32
  ]

||| WindowConfig total size: 32 bytes (8-byte aligned).
||| title_ptr(0..7) + width(8..11) + height(12..15)
||| + resizable(16..19) + decorations(20..23) + fullscreen(24..27)
||| + 4 bytes padding for 8-byte alignment = 32 bytes
public export
windowConfigSize : HasSize WindowConfig 32
windowConfigSize = SizeProof

||| WindowConfig alignment: 8 bytes (due to pointer field).
public export
windowConfigAlign : HasAlignment WindowConfig 8
windowConfigAlign = AlignProof

--------------------------------------------------------------------------------
-- C ABI Compliance
--------------------------------------------------------------------------------

||| Proof that a struct's fields are all properly aligned.
public export
data FieldsAligned : List FieldSpec -> Type where
  FANil  : FieldsAligned []
  FACons : (f : FieldSpec)
         -> So (f.fieldAlign > 0)
         -> FieldsAligned rest
         -> FieldsAligned (f :: rest)

||| C ABI compliance certificate for a type.
||| A type is C ABI compliant if:
||| 1. Its size is known
||| 2. Its alignment is a power of 2
||| 3. Its size is a multiple of its alignment
public export
data CABICompliant : Type -> Nat -> Nat -> Type where
  MkCompliant : {0 t : Type}
              -> {size : Nat}
              -> {align : Nat}
              -> HasSize t size
              -> HasAlignment t align
              -> So (align > 0)
              -> So (size `mod` align == 0)
              -> CABICompliant t size align

||| Result is C ABI compliant (4 bytes, 4-byte aligned).
public export
resultCompliant : CABICompliant Result 4 4
resultCompliant = MkCompliant resultSize resultAlign Oh Oh
