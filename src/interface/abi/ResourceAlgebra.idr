-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unified Resource Algebra & Grade Kernel for Gossamer ABI
|||
||| Integrates the proved mathematics from the hyperpolymath verification estate:
|||   * resource-algebra (Core, Loss, MaxPlus, MinMax, HWM, Separation)
|||   * tropical-types   (worst-case session bounds & bottleneck hub_ceiling)
|||   * occupancy-types  (high-water-mark peak/drift & cut reclamation laws)
|||   * echo-types       (min-plus structured information-loss carrier)
|||
||| Every resource grade in Gossamer (loss/reversibility, worst-case latency,
||| confinement bottleneck, and memory/buffer occupancy) is an instance of
||| `ResourceAlgebra`, with machine-checked separation proofs (`S-1..S-4`)
||| establishing why all four instances are distinct.
|||
||| Zero believe_me, zero postulate, zero assert_total. %default total.

module Gossamer.ABI.ResourceAlgebra

import public Data.Nat
import public Data.List
import public Data.List.Elem
import Gossamer.ABI.Types

%default total

--------------------------------------------------------------------------------
-- 1. The Parametric Resource Algebra Kernel
--------------------------------------------------------------------------------

||| Grade algebra operations: alternatives (`oplus`, `zeroG`) and sequence (`otimes`, `oneG`).
public export
interface ResourceOps g where
  ||| Alternatives (⊕).
  oplus  : g -> g -> g
  ||| Sequence (⊗).
  otimes : g -> g -> g
  ||| Unit of alternatives (𝟘).
  zeroG  : g
  ||| Unit of sequence (𝟙).
  oneG   : g

||| A verified grade algebra: alternatives form an idempotent commutative monoid
||| (`oplus`, `zeroG`); sequence forms a monoid (`otimes`, `oneG`).
public export
interface ResourceOps g => ResourceAlgebra g where
  -- IsAltMonoid oplus zeroG
  altAssoc : (a, b, c : g) -> oplus (oplus a b) c = oplus a (oplus b c)
  altComm  : (a, b : g) -> oplus a b = oplus b a
  altIdem  : (a : g) -> oplus a a = a
  altUnitL : (a : g) -> oplus ResourceAlgebra.zeroG a = a
  -- IsSeqMonoid otimes oneG
  seqAssoc : (a, b, c : g) -> otimes (otimes a b) c = otimes a (otimes b c)
  seqUnitL : (a : g) -> otimes ResourceAlgebra.oneG a = a
  seqUnitR : (a : g) -> otimes a ResourceAlgebra.oneG = a

||| Right unit of alternatives (`IsAltMonoid.unitʳ`).
public export
altUnitR : ResourceAlgebra g => (a : g) -> oplus a ResourceAlgebra.zeroG = a
altUnitR a = trans (altComm a ResourceAlgebra.zeroG) (altUnitL a)

||| The induced order: `a ≼ b` when `b` absorbs `a` under `oplus`.
public export
LeG : ResourceAlgebra g => g -> g -> Type
LeG a b = oplus a b = b

||| `zeroG` is least in the induced order.
public export
zeroLeast : ResourceAlgebra g => (a : g) -> LeG ResourceAlgebra.zeroG a
zeroLeast a = altUnitL a

||| Annihilating resource algebra: `zeroG` absorbs under `otimes`.
||| Separate from `IsDioid` because `HWMGrade` is a dioid with `zeroG = oneG`.
public export
interface ResourceAlgebra g => IsAnnihilating g where
  annihilL : (a : g) -> otimes ResourceAlgebra.zeroG a = ResourceAlgebra.zeroG
  annihilR : (a : g) -> otimes a ResourceAlgebra.zeroG = ResourceAlgebra.zeroG

||| Reflexivity of `LeG`.
public export
leRefl : ResourceAlgebra g => (a : g) -> LeG a a
leRefl a = altIdem a

||| Transitivity of `LeG`.
public export
leTrans : ResourceAlgebra g => {a, b, c : g} -> LeG a b -> LeG b c -> LeG a c
leTrans {a} {b} {c} p q =
  trans (cong (oplus a) (sym q))
  (trans (sym (altAssoc a b c))
  (trans (cong (\x => oplus x c) p) q))

||| Antisymmetry of `LeG`.
public export
leAntisym : ResourceAlgebra g => {a, b : g} -> LeG a b -> LeG b a -> a = b
leAntisym {a} {b} p q = trans (sym q) (trans (altComm b a) p)

||| Left upper-bound law for `oplus`.
public export
oplusUpperL : ResourceAlgebra g => (a, b : g) -> LeG a (oplus a b)
oplusUpperL a b =
  trans (sym (altAssoc a a b)) (cong (\x => oplus x b) (altIdem a))

||| Right upper-bound law for `oplus`.
public export
oplusUpperR : ResourceAlgebra g => (a, b : g) -> LeG b (oplus a b)
oplusUpperR a b =
  trans (cong (oplus b) (altComm a b))
  (trans (sym (altAssoc b b a))
  (trans (cong (\x => oplus x a) (altIdem b))
         (altComm b a)))

||| Four-way interchange for `oplus`.
public export
oplusInterchange : ResourceAlgebra g => (a, b, c, d : g) ->
                   oplus (oplus a b) (oplus c d) = oplus (oplus a c) (oplus b d)
oplusInterchange a b c d =
  trans (altAssoc a b (oplus c d))
  (trans (cong (oplus a)
    (trans (sym (altAssoc b c d))
    (trans (cong (\x => oplus x d) (altComm b c))
           (altAssoc c b d))))
  (sym (altAssoc a c (oplus b d))))

||| Alternatives are monotone in every resource algebra.
public export
oplusMono : ResourceAlgebra g => {a, a', b, b' : g} ->
            LeG a a' -> LeG b b' -> LeG (oplus a b) (oplus a' b')
oplusMono {a} {a'} {b} {b'} p q =
  trans (oplusInterchange a b a' b') (cong2 oplus p q)

||| Ordered resource algebra: sequencing is monotone.
public export
interface ResourceAlgebra g => IsOrdered g where
  otimesMonoL : (c : g) -> {a, b : g} -> LeG a b -> LeG (otimes c a) (otimes c b)
  otimesMonoR : (c : g) -> {a, b : g} -> LeG a b -> LeG (otimes a c) (otimes b c)

||| Sequential composition is monotone in both arguments.
public export
otimesMono : IsOrdered g => {a, a', b, b' : g} ->
             LeG a a' -> LeG b b' -> LeG (otimes a b) (otimes a' b')
otimesMono {a} {a'} {b} {b'} p q = leTrans (otimesMonoR b p) (otimesMonoL a' q)

||| Dioid: sequencing distributes over alternatives.
public export
interface ResourceAlgebra g => IsDioid g where
  distribL : (a, b, c : g) -> otimes a (oplus b c) = oplus (otimes a b) (otimes a c)
  distribR : (a, b, c : g) -> otimes (oplus a b) c = oplus (otimes a c) (otimes b c)

||| Left monotonicity derived from distributivity.
public export
dioidMonoL : IsDioid g => (c : g) -> {a, b : g} -> LeG a b -> LeG (otimes c a) (otimes c b)
dioidMonoL c {a} {b} p = trans (sym (distribL c a b)) (cong (otimes c) p)

||| Right monotonicity derived from distributivity.
public export
dioidMonoR : IsDioid g => (c : g) -> {a, b : g} -> LeG a b -> LeG (otimes a c) (otimes b c)
dioidMonoR c {a} {b} p = trans (sym (distribR a b c)) (cong (\x => otimes x c) p)

--------------------------------------------------------------------------------
-- 2. Self-Contained Arithmetic & Order Lemmas on Nat
--------------------------------------------------------------------------------

public export
lteRefl : (n : Nat) -> LTE n n
lteRefl Z     = LTEZero
lteRefl (S n) = LTESucc (lteRefl n)

public export
lteTrans : {m, n, p : Nat} -> LTE m n -> LTE n p -> LTE m p
lteTrans LTEZero     _           = LTEZero
lteTrans (LTESucc q) (LTESucc r) = LTESucc (lteTrans q r)

public export
plusMonoRLTE : (m : Nat) -> {n, p : Nat} -> LTE n p -> LTE (m + n) (m + p)
plusMonoRLTE Z     q = q
plusMonoRLTE (S m) q = LTESucc (plusMonoRLTE m q)

public export
lteIrrelevant : {m, n : Nat} -> (p, q : LTE m n) -> p = q
lteIrrelevant LTEZero     LTEZero     = Refl
lteIrrelevant (LTESucc p) (LTESucc q) = cong LTESucc (lteIrrelevant p q)

public export
plusZeroR : (n : Nat) -> n + 0 = n
plusZeroR Z     = Refl
plusZeroR (S k) = cong S (plusZeroR k)

public export
plusSuccR : (m, n : Nat) -> S (m + n) = m + S n
plusSuccR Z     n = Refl
plusSuccR (S m) n = cong S (plusSuccR m n)

public export
plusComm : (m, n : Nat) -> m + n = n + m
plusComm Z     n = sym (plusZeroR n)
plusComm (S m) n = trans (cong S (plusComm m n)) (plusSuccR n m)

public export
plusAssoc : (m, n, p : Nat) -> (m + n) + p = m + (n + p)
plusAssoc Z     n p = Refl
plusAssoc (S m) n p = cong S (plusAssoc m n p)

public export
minusZeroR : (n : Nat) -> minus n 0 = n
minusZeroR Z     = Refl
minusZeroR (S k) = Refl

public export
maxZeroRight : (n : Nat) -> maximum n 0 = n
maxZeroRight Z     = Refl
maxZeroRight (S k) = Refl

public export
minZeroRight : (n : Nat) -> minimum n 0 = 0
minZeroRight Z     = Refl
minZeroRight (S k) = Refl

public export
maxIdem : (n : Nat) -> maximum n n = n
maxIdem Z     = Refl
maxIdem (S k) = cong S (maxIdem k)

public export
minIdem : (n : Nat) -> minimum n n = n
minIdem Z     = Refl
minIdem (S k) = cong S (minIdem k)

public export
maxComm : (m, n : Nat) -> maximum m n = maximum n m
maxComm Z     Z     = Refl
maxComm Z     (S n) = Refl
maxComm (S m) Z     = Refl
maxComm (S m) (S n) = cong S (maxComm m n)

public export
minComm : (m, n : Nat) -> minimum m n = minimum n m
minComm Z     Z     = Refl
minComm Z     (S n) = Refl
minComm (S m) Z     = Refl
minComm (S m) (S n) = cong S (minComm m n)

public export
maxAssoc : (m, n, p : Nat) -> maximum (maximum m n) p = maximum m (maximum n p)
maxAssoc Z     n     p     = Refl
maxAssoc (S m) Z     p     = Refl
maxAssoc (S m) (S n) Z     = Refl
maxAssoc (S m) (S n) (S p) = cong S (maxAssoc m n p)

public export
minAssoc : (m, n, p : Nat) -> minimum (minimum m n) p = minimum m (minimum n p)
minAssoc Z     n     p     = Refl
minAssoc (S m) Z     p     = Refl
minAssoc (S m) (S n) Z     = Refl
minAssoc (S m) (S n) (S p) = cong S (minAssoc m n p)

public export
maxLeftUpperBound : (m, n : Nat) -> LTE m (maximum m n)
maxLeftUpperBound Z     n     = LTEZero
maxLeftUpperBound (S m) Z     = lteRefl (S m)
maxLeftUpperBound (S m) (S n) = LTESucc (maxLeftUpperBound m n)

public export
maxRightUpperBound : (m, n : Nat) -> LTE n (maximum m n)
maxRightUpperBound Z     n     = lteRefl n
maxRightUpperBound (S m) Z     = LTEZero
maxRightUpperBound (S m) (S n) = LTESucc (maxRightUpperBound m n)

public export
lteSuccR : (n : Nat) -> LTE n (S n)
lteSuccR Z     = LTEZero
lteSuccR (S n) = LTESucc (lteSuccR n)

public export
lteAddRightNat : (m, n : Nat) -> LTE m (m + n)
lteAddRightNat Z     n = LTEZero
lteAddRightNat (S m) n = LTESucc (lteAddRightNat m n)

public export
lteAddLeftNat : (b, c : Nat) -> LTE c (b + c)
lteAddLeftNat Z     c = lteRefl c
lteAddLeftNat (S b) c = lteTrans (lteAddLeftNat b c) (lteSuccR (b + c))

public export
plusLteMonoR : (c, a, b : Nat) -> LTE a b -> LTE (a + c) (b + c)
plusLteMonoR c Z     b     LTEZero     = lteAddLeftNat b c
plusLteMonoR c (S a) (S b) (LTESucc p) = LTESucc (plusLteMonoR c a b p)

public export
plusMinusLteNat : (n, p : Nat) -> LTE n p -> minus p n + n = p
plusMinusLteNat Z     p     LTEZero     =
  trans (cong (\x => x + 0) (minusZeroR p)) (plusZeroR p)
plusMinusLteNat (S n) (S p) (LTESucc q) =
  trans (sym (plusSuccR (minus p n) n)) (cong S (plusMinusLteNat n p q))

public export
maxDup : (p, x, y : Nat) ->
         maximum (maximum p x) (maximum p y) = maximum p (maximum x y)
maxDup p x y =
  trans (maxAssoc p x (maximum p y))
  (trans (cong (maximum p) (sym (maxAssoc x p y)))
  (trans (cong (\z => maximum p (maximum z y)) (maxComm x p))
  (trans (cong (maximum p) (maxAssoc p x y))
  (trans (sym (maxAssoc p p (maximum x y)))
         (cong (\z => maximum z (maximum x y)) (maxIdem p))))))

public export
maxInterchange : (a, b, c, d : Nat) ->
                 maximum (maximum a b) (maximum c d)
               = maximum (maximum a c) (maximum b d)
maxInterchange a b c d =
  trans (maxAssoc a b (maximum c d))
  (trans (cong (maximum a)
    (trans (sym (maxAssoc b c d))
    (trans (cong (\z => maximum z d) (maxComm b c))
           (maxAssoc c b d))))
  (sym (maxAssoc a c (maximum b d))))

public export
plusDistribLMax : (a, b, c : Nat) -> a + maximum b c = maximum (a + b) (a + c)
plusDistribLMax Z     b c = Refl
plusDistribLMax (S a) b c = cong S (plusDistribLMax a b c)

public export
plusDistribRMax : (a, b, c : Nat) -> maximum a b + c = maximum (a + c) (b + c)
plusDistribRMax a b c =
  trans (plusComm (maximum a b) c)
  (trans (plusDistribLMax c a b)
  (trans (cong (\z => maximum z (c + b)) (plusComm c a))
         (cong (maximum (a + c)) (plusComm c b))))

public export
maxMonoLTE : {a, a', b, b' : Nat} -> LTE a a' -> LTE b b' ->
             LTE (maximum a b) (maximum a' b')
maxMonoLTE {a' = a'} {b' = b'}  LTEZero     q          =
  lteTrans q (maxRightUpperBound a' b')
maxMonoLTE {a' = S k} {b' = b'} (LTESucc p) LTEZero    =
  lteTrans (LTESucc p) (maxLeftUpperBound (S k) b')
maxMonoLTE                      (LTESucc p) (LTESucc q) = LTESucc (maxMonoLTE p q)

public export
maxAbsorbLTE : {n, p : Nat} -> LTE n p -> maximum p n = p
maxAbsorbLTE {p} LTEZero     = maxZeroRight p
maxAbsorbLTE     (LTESucc q) = cong S (maxAbsorbLTE q)

public export
plusDistribLMin : (a, b, c : Nat) -> a + minimum b c = minimum (a + b) (a + c)
plusDistribLMin Z     b c = Refl
plusDistribLMin (S a) b c = cong S (plusDistribLMin a b c)

public export
plusDistribRMin : (a, b, c : Nat) -> minimum a b + c = minimum (a + c) (b + c)
plusDistribRMin a b c =
  trans (plusComm (minimum a b) c)
  (trans (plusDistribLMin c a b)
  (trans (cong (\z => minimum z (c + b)) (plusComm c a))
         (cong (minimum (a + c)) (plusComm c b))))

public export
succInj : {m, n : Nat} -> S m = S n -> m = n
succInj Refl = Refl

public export
minimumOfLTE : {k, n : Nat} -> LTE k n -> minimum n k = k
minimumOfLTE {n} LTEZero     = minZeroRight n
minimumOfLTE     (LTESucc q) = cong S (minimumOfLTE q)

public export
lteOfMinimum : (n, k : Nat) -> minimum n k = k -> LTE k n
lteOfMinimum n     Z     _    = LTEZero
lteOfMinimum Z     (S k) Refl impossible
lteOfMinimum (S n) (S k) prf  = LTESucc (lteOfMinimum n k (succInj prf))

public export
maximumOfLTE : {m, n : Nat} -> LTE m n -> maximum m n = n
maximumOfLTE LTEZero     = Refl
maximumOfLTE (LTESucc q) = cong S (maximumOfLTE q)

public export
lteOfMaximum : (m, n : Nat) -> maximum m n = n -> LTE m n
lteOfMaximum Z     n     _    = LTEZero
lteOfMaximum (S m) Z     Refl impossible
lteOfMaximum (S m) (S n) prf  = LTESucc (lteOfMaximum m n (succInj prf))

public export
maxLub : {a, b, c : Nat} -> LTE a c -> LTE b c -> LTE (maximum a b) c
maxLub LTEZero     q           = q
maxLub (LTESucc p) LTEZero     = LTESucc p
maxLub (LTESucc p) (LTESucc q) = LTESucc (maxLub p q)

public export
minOfLTE : {m, n : Nat} -> LTE m n -> minimum m n = m
minOfLTE {m} {n} le = trans (minComm m n) (minimumOfLTE le)

public export
maxDistribLMin : (a, b, c : Nat) ->
                 maximum a (minimum b c) = minimum (maximum a b) (maximum a c)
maxDistribLMin Z     b     c     = Refl
maxDistribLMin (S a) Z     c     = sym (minOfLTE (maxLeftUpperBound (S a) c))
maxDistribLMin (S a) (S b) Z     = cong S (sym (minimumOfLTE (maxLeftUpperBound a b)))
maxDistribLMin (S a) (S b) (S c) = cong S (maxDistribLMin a b c)

public export
maxDistribRMin : (a, b, c : Nat) ->
                 maximum (minimum a b) c = minimum (maximum a c) (maximum b c)
maxDistribRMin a b c =
  trans (maxComm (minimum a b) c)
  (trans (maxDistribLMin c a b)
         (cong2 minimum (maxComm c a) (maxComm c b)))

--------------------------------------------------------------------------------
-- 3. Instance 1: LossGrade (Min-Plus on Nat ∪ {∞} — echo-types & januskey)
--------------------------------------------------------------------------------

||| ℕ ∪ {∞}: `Finite 0` is lossless (`keep`), `Infinity` is total collapse (`obliterate`).
public export
data LossGrade : Type where
  Finite   : (n : Nat) -> LossGrade
  Infinity : LossGrade

public export
Eq LossGrade where
  (Finite a) == (Finite b) = a == b
  Infinity   == Infinity   = True
  _          == _          = False

public export
Show LossGrade where
  show (Finite n) = "Finite(" ++ show n ++ ")"
  show Infinity   = "Infinity"

||| Sequence: loss accumulates (`+`), `Infinity` absorbs.
public export
lossSeq : LossGrade -> LossGrade -> LossGrade
lossSeq (Finite m) (Finite n) = Finite (m + n)
lossSeq (Finite _) Infinity   = Infinity
lossSeq Infinity   _          = Infinity

||| Alternatives: the less lossy option (`min`).
public export
lossAlt : LossGrade -> LossGrade -> LossGrade
lossAlt (Finite m) (Finite n) = Finite (minimum m n)
lossAlt (Finite m) Infinity   = Finite m
lossAlt Infinity   g          = g

public export
finiteInjective : {m, n : Nat} -> Finite m = Finite n -> m = n
finiteInjective Refl = Refl

public export
lossAltAssoc : (a, b, c : LossGrade) ->
               lossAlt (lossAlt a b) c = lossAlt a (lossAlt b c)
lossAltAssoc (Finite a) (Finite b) (Finite c) = cong Finite (minAssoc a b c)
lossAltAssoc (Finite a) (Finite b) Infinity   = Refl
lossAltAssoc (Finite a) Infinity   c          = Refl
lossAltAssoc Infinity   b          c          = Refl

public export
lossAltComm : (a, b : LossGrade) -> lossAlt a b = lossAlt b a
lossAltComm (Finite a) (Finite b) = cong Finite (minComm a b)
lossAltComm (Finite a) Infinity   = Refl
lossAltComm Infinity   (Finite b) = Refl
lossAltComm Infinity   Infinity   = Refl

public export
lossAltIdem : (a : LossGrade) -> lossAlt a a = a
lossAltIdem (Finite a) = cong Finite (minIdem a)
lossAltIdem Infinity   = Refl

public export
lossSeqAssoc : (a, b, c : LossGrade) ->
               lossSeq (lossSeq a b) c = lossSeq a (lossSeq b c)
lossSeqAssoc (Finite a) (Finite b) (Finite c) = cong Finite (plusAssoc a b c)
lossSeqAssoc (Finite a) (Finite b) Infinity   = Refl
lossSeqAssoc (Finite a) Infinity   c          = Refl
lossSeqAssoc Infinity   b          c          = Refl

public export
lossSeqUnitL : (a : LossGrade) -> lossSeq (Finite 0) a = a
lossSeqUnitL (Finite a) = Refl
lossSeqUnitL Infinity   = Refl

public export
lossSeqUnitR : (a : LossGrade) -> lossSeq a (Finite 0) = a
lossSeqUnitR (Finite a) = cong Finite (plusZeroR a)
lossSeqUnitR Infinity   = Refl

public export
ResourceOps LossGrade where
  oplus  = lossAlt
  otimes = lossSeq
  zeroG  = Infinity
  oneG   = Finite 0

public export
ResourceAlgebra LossGrade where
  altAssoc = lossAltAssoc
  altComm  = lossAltComm
  altIdem  = lossAltIdem
  altUnitL = \_ => Refl
  seqAssoc = lossSeqAssoc
  seqUnitL = lossSeqUnitL
  seqUnitR = lossSeqUnitR

public export
lossDistribL : (a, b, c : LossGrade) ->
               lossSeq a (lossAlt b c) = lossAlt (lossSeq a b) (lossSeq a c)
lossDistribL (Finite a) (Finite b) (Finite c) = cong Finite (plusDistribLMin a b c)
lossDistribL (Finite a) (Finite b) Infinity   = Refl
lossDistribL (Finite a) Infinity   c          = Refl
lossDistribL Infinity   b          c          = Refl

public export
lossDistribR : (a, b, c : LossGrade) ->
               lossSeq (lossAlt a b) c = lossAlt (lossSeq a c) (lossSeq b c)
lossDistribR (Finite a) (Finite b) (Finite c) = cong Finite (plusDistribRMin a b c)
lossDistribR (Finite a) (Finite b) Infinity   = Refl
lossDistribR (Finite a) Infinity   (Finite c) = Refl
lossDistribR (Finite a) Infinity   Infinity   = Refl
lossDistribR Infinity   b          c          = Refl

public export
IsDioid LossGrade where
  distribL = lossDistribL
  distribR = lossDistribR

public export
IsOrdered LossGrade where
  otimesMonoL = dioidMonoL
  otimesMonoR = dioidMonoR

public export
lossAnnihilR : (a : LossGrade) -> lossSeq a Infinity = Infinity
lossAnnihilR (Finite _) = Refl
lossAnnihilR Infinity   = Refl

public export
IsAnnihilating LossGrade where
  annihilL = \_ => Refl
  annihilR = lossAnnihilR

public export
finiteNotInfinity : {n : Nat} -> Not (Finite n = Infinity)
finiteNotInfinity Refl impossible

public export
lossLeOfLTE : {k, n : Nat} -> LTE k n -> LeG (Finite n) (Finite k)
lossLeOfLTE le = cong Finite (minimumOfLTE le)

public export
lteOfLossLe : (n, k : Nat) -> LeG (Finite n) (Finite k) -> LTE k n
lteOfLossLe n k prf = lteOfMinimum n k (finiteInjective prf)

public export
lossLeOne : (g : LossGrade) -> LeG g (Finite 0)
lossLeOne (Finite n) = cong Finite (minZeroRight n)
lossLeOne Infinity   = Refl

--------------------------------------------------------------------------------
-- 4. Instance 2: MaxPlusGrade (Max-Plus on Nat ∪ {−∞} — tropical-types)
--------------------------------------------------------------------------------

||| ℕ ∪ {−∞}: worst-case execution cost / latency grade.
public export
data MaxPlusGrade : Type where
  Val : (n : Nat) -> MaxPlusGrade
  Bot : MaxPlusGrade

public export
Eq MaxPlusGrade where
  (Val a) == (Val b) = a == b
  Bot     == Bot     = True
  _       == _       = False

public export
Show MaxPlusGrade where
  show (Val n) = "Val(" ++ show n ++ ")"
  show Bot     = "Bot"

public export
maxPlusAlt : MaxPlusGrade -> MaxPlusGrade -> MaxPlusGrade
maxPlusAlt Bot     b       = b
maxPlusAlt (Val m) Bot     = Val m
maxPlusAlt (Val m) (Val n) = Val (maximum m n)

public export
maxPlusSeq : MaxPlusGrade -> MaxPlusGrade -> MaxPlusGrade
maxPlusSeq Bot     _       = Bot
maxPlusSeq (Val m) Bot     = Bot
maxPlusSeq (Val m) (Val n) = Val (m + n)

public export
valInjective : {m, n : Nat} -> Val m = Val n -> m = n
valInjective Refl = Refl

public export
maxPlusAltAssoc : (a, b, c : MaxPlusGrade) ->
                  maxPlusAlt (maxPlusAlt a b) c = maxPlusAlt a (maxPlusAlt b c)
maxPlusAltAssoc (Val a) (Val b) (Val c) = cong Val (maxAssoc a b c)
maxPlusAltAssoc (Val a) (Val b) Bot     = Refl
maxPlusAltAssoc (Val a) Bot     c       = Refl
maxPlusAltAssoc Bot     b       c       = Refl

public export
maxPlusAltComm : (a, b : MaxPlusGrade) -> maxPlusAlt a b = maxPlusAlt b a
maxPlusAltComm (Val a) (Val b) = cong Val (maxComm a b)
maxPlusAltComm (Val a) Bot     = Refl
maxPlusAltComm Bot     (Val b) = Refl
maxPlusAltComm Bot     Bot     = Refl

public export
maxPlusAltIdem : (a : MaxPlusGrade) -> maxPlusAlt a a = a
maxPlusAltIdem (Val a) = cong Val (maxIdem a)
maxPlusAltIdem Bot     = Refl

public export
maxPlusSeqAssoc : (a, b, c : MaxPlusGrade) ->
                  maxPlusSeq (maxPlusSeq a b) c = maxPlusSeq a (maxPlusSeq b c)
maxPlusSeqAssoc (Val a) (Val b) (Val c) = cong Val (plusAssoc a b c)
maxPlusSeqAssoc (Val a) (Val b) Bot     = Refl
maxPlusSeqAssoc (Val a) Bot     c       = Refl
maxPlusSeqAssoc Bot     b       c       = Refl

public export
maxPlusSeqUnitL : (a : MaxPlusGrade) -> maxPlusSeq (Val 0) a = a
maxPlusSeqUnitL (Val a) = Refl
maxPlusSeqUnitL Bot     = Refl

public export
maxPlusSeqUnitR : (a : MaxPlusGrade) -> maxPlusSeq a (Val 0) = a
maxPlusSeqUnitR (Val a) = cong Val (plusZeroR a)
maxPlusSeqUnitR Bot     = Refl

public export
ResourceOps MaxPlusGrade where
  oplus  = maxPlusAlt
  otimes = maxPlusSeq
  zeroG  = Bot
  oneG   = Val 0

public export
ResourceAlgebra MaxPlusGrade where
  altAssoc = maxPlusAltAssoc
  altComm  = maxPlusAltComm
  altIdem  = maxPlusAltIdem
  altUnitL = \_ => Refl
  seqAssoc = maxPlusSeqAssoc
  seqUnitL = maxPlusSeqUnitL
  seqUnitR = maxPlusSeqUnitR

public export
maxPlusDistribL : (a, b, c : MaxPlusGrade) ->
                  maxPlusSeq a (maxPlusAlt b c)
                = maxPlusAlt (maxPlusSeq a b) (maxPlusSeq a c)
maxPlusDistribL (Val a) (Val b) (Val c) = cong Val (plusDistribLMax a b c)
maxPlusDistribL (Val a) (Val b) Bot     = Refl
maxPlusDistribL (Val a) Bot     (Val c) = Refl
maxPlusDistribL (Val a) Bot     Bot     = Refl
maxPlusDistribL Bot     b       c       = Refl

public export
maxPlusDistribR : (a, b, c : MaxPlusGrade) ->
                  maxPlusSeq (maxPlusAlt a b) c
                = maxPlusAlt (maxPlusSeq a c) (maxPlusSeq b c)
maxPlusDistribR (Val a) (Val b) (Val c) = cong Val (plusDistribRMax a b c)
maxPlusDistribR (Val a) (Val b) Bot     = Refl
maxPlusDistribR (Val a) Bot     (Val c) = Refl
maxPlusDistribR (Val a) Bot     Bot     = Refl
maxPlusDistribR Bot     (Val b) (Val c) = Refl
maxPlusDistribR Bot     (Val b) Bot     = Refl
maxPlusDistribR Bot     Bot     c       = Refl

public export
IsDioid MaxPlusGrade where
  distribL = maxPlusDistribL
  distribR = maxPlusDistribR

public export
IsOrdered MaxPlusGrade where
  otimesMonoL = dioidMonoL
  otimesMonoR = dioidMonoR

public export
maxPlusAnnihilR : (a : MaxPlusGrade) -> maxPlusSeq a Bot = Bot
maxPlusAnnihilR (Val _) = Refl
maxPlusAnnihilR Bot     = Refl

public export
IsAnnihilating MaxPlusGrade where
  annihilL = \_ => Refl
  annihilR = maxPlusAnnihilR

public export
maxPlusLeOfLTE : {m, n : Nat} -> LTE m n -> LeG (Val m) (Val n)
maxPlusLeOfLTE le = cong Val (maximumOfLTE le)

public export
lteOfMaxPlusLe : (m, n : Nat) -> LeG (Val m) (Val n) -> LTE m n
lteOfMaxPlusLe m n prf = lteOfMaximum m n (valInjective prf)

--------------------------------------------------------------------------------
-- 5. Instance 3: MinMax Bottleneck Algebra & hubCeiling (tropical-types)
--------------------------------------------------------------------------------

||| Sequence in the bottleneck algebra: the worst step (`max`).
public export
minMaxSeq : LossGrade -> LossGrade -> LossGrade
minMaxSeq Infinity   _          = Infinity
minMaxSeq (Finite m) Infinity   = Infinity
minMaxSeq (Finite m) (Finite n) = Finite (maximum m n)

public export
minMaxSeqAssoc : (a, b, c : LossGrade) ->
                 minMaxSeq (minMaxSeq a b) c = minMaxSeq a (minMaxSeq b c)
minMaxSeqAssoc (Finite a) (Finite b) (Finite c) = cong Finite (maxAssoc a b c)
minMaxSeqAssoc (Finite a) (Finite b) Infinity   = Refl
minMaxSeqAssoc (Finite a) Infinity   c          = Refl
minMaxSeqAssoc Infinity   b          c          = Refl

public export
minMaxSeqUnitL : (a : LossGrade) -> minMaxSeq (Finite 0) a = a
minMaxSeqUnitL (Finite a) = Refl
minMaxSeqUnitL Infinity   = Refl

public export
minMaxSeqUnitR : (a : LossGrade) -> minMaxSeq a (Finite 0) = a
minMaxSeqUnitR (Finite a) = cong Finite (maxZeroRight a)
minMaxSeqUnitR Infinity   = Refl

public export
minMaxDistribL : (a, b, c : LossGrade) ->
                 minMaxSeq a (lossAlt b c) = lossAlt (minMaxSeq a b) (minMaxSeq a c)
minMaxDistribL (Finite a) (Finite b) (Finite c) = cong Finite (maxDistribLMin a b c)
minMaxDistribL (Finite a) (Finite b) Infinity   = Refl
minMaxDistribL (Finite a) Infinity   c          = Refl
minMaxDistribL Infinity   b          c          = Refl

public export
minMaxDistribR : (a, b, c : LossGrade) ->
                 minMaxSeq (lossAlt a b) c = lossAlt (minMaxSeq a c) (minMaxSeq b c)
minMaxDistribR (Finite a) (Finite b) (Finite c) = cong Finite (maxDistribRMin a b c)
minMaxDistribR (Finite a) (Finite b) Infinity   = Refl
minMaxDistribR (Finite a) Infinity   (Finite c) = Refl
minMaxDistribR (Finite a) Infinity   Infinity   = Refl
minMaxDistribR Infinity   b          c          = Refl

||| Bottleneck of a path of confinement/adapter gates.
public export
pathBottleneck : List LossGrade -> LossGrade
pathBottleneck []        = Finite 0
pathBottleneck (e :: xs) = minMaxSeq e (pathBottleneck xs)

||| Left upper bound for `minMaxSeq` in the `LossGrade` order (`LeG b (minMaxSeq a b)`).
public export
minMaxUpperL : (a, b : LossGrade) -> LeG (minMaxSeq a b) a
minMaxUpperL Infinity   _          = Refl
minMaxUpperL (Finite m) Infinity   = Refl
minMaxUpperL (Finite m) (Finite n) =
  cong Finite (minimumOfLTE (maxLeftUpperBound m n))

||| Right upper bound for `minMaxSeq` in the `LossGrade` order.
public export
minMaxUpperR : (a, b : LossGrade) -> LeG (minMaxSeq a b) b
minMaxUpperR Infinity   _          = Refl
minMaxUpperR (Finite m) Infinity   = Refl
minMaxUpperR (Finite m) (Finite n) =
  cong Finite (minimumOfLTE (maxRightUpperBound m n))

||| `hubCeiling` (tropical-types `hub_ceiling`): the bottleneck of a gate chain
||| ceilings every individual gate along the path (`LeG (pathBottleneck edges) e`).
public export
hubCeiling : {edges : List LossGrade} -> (e : LossGrade) ->
             Elem e edges -> LeG (pathBottleneck edges) e
hubCeiling {edges = (x :: xs)} x Here =
  minMaxUpperL x (pathBottleneck xs)
hubCeiling {edges = (y :: xs)} e (There later) =
  leTrans (minMaxUpperR y (pathBottleneck xs)) (hubCeiling e later)

--------------------------------------------------------------------------------
-- 6. Instance 4: HWMGrade (High-Water Mark Occupancy — occupancy-types)
--------------------------------------------------------------------------------

||| High-water-mark occupancy grade: `peak` live resources reached during a phase
||| and `drift` live resources still held at the end (`drift <= peak`).
public export
record HWMGrade where
  constructor MkHWM
  peak    : Nat
  drift   : Nat
  bounded : LTE drift peak

public export
Eq HWMGrade where
  (MkHWM p1 d1 _) == (MkHWM p2 d2 _) = p1 == p2 && d1 == d2

public export
Show HWMGrade where
  show (MkHWM p d _) = "HWM(peak=" ++ show p ++ ", drift=" ++ show d ++ ")"

public export
hwmEq : {p, p', n, n' : Nat} -> {b : LTE n p} -> {b' : LTE n' p'} ->
        p = p' -> n = n' -> MkHWM p n b = MkHWM p' n' b'
hwmEq {p} {n} {b} {b'} Refl Refl = cong (MkHWM p n) (lteIrrelevant b b')

||| Sequence: phase `b` starts from phase `a`'s `drift`, not its `peak`.
public export
hwmSeq : HWMGrade -> HWMGrade -> HWMGrade
hwmSeq (MkHWM p1 n1 b1) (MkHWM p2 n2 b2) =
  MkHWM (maximum p1 (n1 + p2)) (n1 + n2)
        (lteTrans (plusMonoRLTE n1 b2) (maxRightUpperBound p1 (n1 + p2)))

||| Alternatives: componentwise `max`.
public export
hwmAlt : HWMGrade -> HWMGrade -> HWMGrade
hwmAlt (MkHWM p1 n1 b1) (MkHWM p2 n2 b2) =
  MkHWM (maximum p1 p2) (maximum n1 n2) (maxMonoLTE b1 b2)

||| Zero and one of HWM: 0 peak, 0 drift.
public export
hwmZero : HWMGrade
hwmZero = MkHWM 0 0 LTEZero

public export
hwmAltAssoc : (a, b, c : HWMGrade) -> hwmAlt (hwmAlt a b) c = hwmAlt a (hwmAlt b c)
hwmAltAssoc (MkHWM p n _) (MkHWM p' n' _) (MkHWM p'' n'' _) =
  hwmEq (maxAssoc p p' p'') (maxAssoc n n' n'')

public export
hwmAltComm : (a, b : HWMGrade) -> hwmAlt a b = hwmAlt b a
hwmAltComm (MkHWM p n _) (MkHWM p' n' _) =
  hwmEq (maxComm p p') (maxComm n n')

public export
hwmAltIdem : (a : HWMGrade) -> hwmAlt a a = a
hwmAltIdem (MkHWM p n _) = hwmEq (maxIdem p) (maxIdem n)

public export
hwmAltUnitL : (a : HWMGrade) -> hwmAlt ResourceAlgebra.hwmZero a = a
hwmAltUnitL (MkHWM p n _) = hwmEq Refl Refl

public export
hwmSeqAssoc : (a, b, c : HWMGrade) -> hwmSeq (hwmSeq a b) c = hwmSeq a (hwmSeq b c)
hwmSeqAssoc (MkHWM p1 n1 _) (MkHWM p2 n2 _) (MkHWM p3 n3 _) =
  hwmEq
    (trans (cong (maximum (maximum p1 (n1 + p2))) (plusAssoc n1 n2 p3))
    (trans (maxAssoc p1 (n1 + p2) (n1 + (n2 + p3)))
           (cong (maximum p1) (sym (plusDistribLMax n1 p2 (n2 + p3))))))
    (plusAssoc n1 n2 n3)

public export
hwmSeqUnitL : (a : HWMGrade) -> hwmSeq ResourceAlgebra.hwmZero a = a
hwmSeqUnitL (MkHWM p n _) = hwmEq Refl Refl

public export
hwmSeqUnitR : (a : HWMGrade) -> hwmSeq a ResourceAlgebra.hwmZero = a
hwmSeqUnitR (MkHWM p n b) =
  hwmEq (trans (cong (maximum p) (plusZeroR n)) (maxAbsorbLTE b))
        (plusZeroR n)

public export
ResourceOps HWMGrade where
  oplus  = hwmAlt
  otimes = hwmSeq
  zeroG  = hwmZero
  oneG   = hwmZero

public export
ResourceAlgebra HWMGrade where
  altAssoc = hwmAltAssoc
  altComm  = hwmAltComm
  altIdem  = hwmAltIdem
  altUnitL = hwmAltUnitL
  seqAssoc = hwmSeqAssoc
  seqUnitL = hwmSeqUnitL
  seqUnitR = hwmSeqUnitR

public export
hwmDistribL : (a, b, c : HWMGrade) ->
              hwmSeq a (hwmAlt b c) = hwmAlt (hwmSeq a b) (hwmSeq a c)
hwmDistribL (MkHWM p n _) (MkHWM p2 n2 _) (MkHWM p3 n3 _) =
  hwmEq (trans (cong (maximum p) (plusDistribLMax n p2 p3))
               (sym (maxDup p (n + p2) (n + p3))))
        (plusDistribLMax n n2 n3)

public export
hwmDistribR : (a, b, c : HWMGrade) ->
              hwmSeq (hwmAlt a b) c = hwmAlt (hwmSeq a c) (hwmSeq b c)
hwmDistribR (MkHWM p2 n2 _) (MkHWM p3 n3 _) (MkHWM p n _) =
  hwmEq (trans (cong (maximum (maximum p2 p3)) (plusDistribRMax n2 n3 p))
               (maxInterchange p2 p3 (n2 + p) (n3 + p)))
        (plusDistribRMax n2 n3 n)

public export
IsDioid HWMGrade where
  distribL = hwmDistribL
  distribR = hwmDistribR

public export
IsOrdered HWMGrade where
  otimesMonoL = dioidMonoL
  otimesMonoR = dioidMonoR

--------------------------------------------------------------------------------
-- 7. Occupancy Reclamation Laws (occupancy-types R-1..R-5)
--------------------------------------------------------------------------------

private
ltPlusPositive : (m : Nat) -> {n : Nat} -> LT 0 n -> LT m (m + n)
ltPlusPositive Z     {n = S k} (LTESucc _) = LTESucc LTEZero
ltPlusPositive (S m) {n = S k} (LTESucc p) = LTESucc (ltPlusPositive m (LTESucc p))

||| Grade of a multi-phase timeline in any `ResourceAlgebra`.
public export
timelineGrade : ResourceAlgebra g => List g -> g
timelineGrade []        = oneG
timelineGrade (x :: xs) = otimes x (timelineGrade xs)

||| R-1 (`cut-factor`): Cutting a timeline anywhere factors its grade.
public export
cutFactor : ResourceAlgebra g => (xs, ys : List g) ->
            timelineGrade (xs ++ ys) = otimes (timelineGrade xs) (timelineGrade ys)
cutFactor []        ys = sym (seqUnitL (timelineGrade ys))
cutFactor (x :: xs) ys =
  trans (cong (otimes x) (cutFactor xs ys))
        (sym (seqAssoc x (timelineGrade xs) (timelineGrade ys)))

||| R-2 (`reclaim-law`): The suffix after a cut starts from the prefix's drift.
public export
reclaimLaw : (a, b : HWMGrade) ->
             peak (hwmSeq a b) = maximum (peak a) (drift a + peak b)
reclaimLaw (MkHWM _ _ _) (MkHWM _ _ _) = Refl

||| R-3 (`occupancy≤cost`): Peak occupancy of a sequence never exceeds the sum of peaks.
public export
occupancyLeCost : (a, b : HWMGrade) -> LTE (peak (hwmSeq a b)) (peak a + peak b)
occupancyLeCost (MkHWM p1 n1 b1) (MkHWM p2 n2 b2) =
  maxLub (lteAddRightNat p1 p2) (plusLteMonoR p2 n1 p1 b1)

private
noReclaimAux : (p, n, p2 : Nat) -> p = n -> maximum p (n + p2) = p + p2
noReclaimAux p p p2 Refl =
  trans (maxComm p (p + p2)) (maxAbsorbLTE (lteAddRightNat p p2))

||| R-4a (`no-reclaim`): When `peak a = drift a`, nothing is reclaimed and occupancy = cost.
public export
noReclaim : (a : HWMGrade) -> peak a = drift a -> (c : HWMGrade) ->
            peak (hwmSeq a c) = peak a + peak c
noReclaim (MkHWM p n _) eq (MkHWM p2 _ _) = noReclaimAux p n p2 eq

||| R-4b (`reclaimed`): When `drift a < peak a` and `0 < peak c`, occupancy is strictly below cost.
public export
reclaimed : (a, c : HWMGrade) -> LT (drift a) (peak a) -> LT 0 (peak c) ->
            LT (peak (hwmSeq a c)) (peak a + peak c)
reclaimed (MkHWM p1 n1 b1) (MkHWM p2 n2 b2) lt pos =
  maxLub (ltPlusPositive p1 pos) (plusLteMonoR p2 (S n1) p1 lt)

||| R-2 for multi-phase timelines (`occupancy-at-cut`).
public export
occupancyAtCut : (xs, ys : List HWMGrade) ->
                 peak (timelineGrade (xs ++ ys))
               = maximum (peak (timelineGrade xs))
                         (drift (timelineGrade xs) + peak (timelineGrade ys))
occupancyAtCut xs ys =
  trans (cong peak (cutFactor xs ys)) (reclaimLaw (timelineGrade xs) (timelineGrade ys))

||| Amount of live state reclaimed at a phase boundary: `peak - drift`.
public export
reclaimedAt : HWMGrade -> Nat
reclaimedAt g = minus (peak g) (drift g)

||| Reclaimed state plus remaining drift equals the peak exactly.
public export
reclaimedPlusDrift : (g : HWMGrade) -> reclaimedAt g + drift g = peak g
reclaimedPlusDrift (MkHWM p n b) = plusMinusLteNat n p b

--------------------------------------------------------------------------------
-- 8. Separation Theorems S-1..S-4 (Why the 4 Algebras Cannot Collapse)
--------------------------------------------------------------------------------

public export
hwmTwo : HWMGrade
hwmTwo = MkHWM 2 0 LTEZero

public export
hwmThree : HWMGrade
hwmThree = MkHWM 3 0 LTEZero

private
threeNotFive : Not (the Nat 3 = 5)
threeNotFive Refl impossible

private
twoNotThree : Not (the Nat 2 = 3)
twoNotThree Refl impossible

||| S-1: Occupancy is not cost (peaks 2 and 3 with 0 drift have peak 3, cost 5).
public export
occupancyIsNotCost : Not (peak (hwmSeq ResourceAlgebra.hwmTwo ResourceAlgebra.hwmThree) = 5)
occupancyIsNotCost = threeNotFive

||| S-2: Loss alternatives pick `min` (2), whereas MaxPlus alternatives pick `max` (3).
public export
alternativesDiffer : Not (lossAlt (Finite 2) (Finite 3) = Finite 3)
alternativesDiffer p = twoNotThree (finiteInjective p)

||| S-3: Induced orders run in opposite directions (`Val 1 ≼ Val 2` vs `Finite 2 ≼ Finite 1`).
public export
maxPlusOrder : LeG (Val 1) (Val 2)
maxPlusOrder = Refl

public export
lossOrderReversed : LeG (Finite 2) (Finite 1)
lossOrderReversed = Refl

||| S-4: Bottleneck sequence (`minMaxSeq`, 3) is not cumulative loss (`lossSeq`, 5).
public export
bottleneckIsNotSum : Not (minMaxSeq (Finite 2) (Finite 3) = lossSeq (Finite 2) (Finite 3))
bottleneckIsNotSum p = threeNotFive (finiteInjective p)

--------------------------------------------------------------------------------
-- 9. Gossamer ActivityLevel Frame-Budget Grading in MaxPlus
--------------------------------------------------------------------------------

||| Canonical frame/IPC processing budget (in work units per tick) for each
||| Gossamer `ActivityLevel` (`Types.idr`).
public export
activityBudget : ActivityLevel -> MaxPlusGrade
activityBudget Paused   = Val 0
activityBudget Low      = Val 1
activityBudget Mid      = Val 15
activityBudget High     = Val 30
activityBudget Realtime = Val 60

||| `Paused` is the multiplicative identity `oneG = Val 0` of `MaxPlusGrade`.
public export
pausedIsZeroBudget : activityBudget Paused = ResourceAlgebra.oneG
pausedIsZeroBudget = Refl

||| Activity levels are monotonically ordered in `MaxPlusGrade`:
||| `Paused ≼ Low ≼ Mid ≼ High ≼ Realtime`.
public export
pausedLeLow : LeG (activityBudget Paused) (activityBudget Low)
pausedLeLow = Refl

public export
lowLeMid : LeG (activityBudget Low) (activityBudget Mid)
lowLeMid = Refl

public export
midLeHigh : LeG (activityBudget Mid) (activityBudget High)
midLeHigh = Refl

public export
highLeRealtime : LeG (activityBudget High) (activityBudget Realtime)
highLeRealtime = Refl
