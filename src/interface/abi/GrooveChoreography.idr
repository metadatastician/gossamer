-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Graded Multiparty Choreographies & K-CUT-LOSS for Gossamer Groove
|||
||| Integrates the proved mathematics from `hyperpolymath/choreographic-types`
||| (`Party`, `Global`, `Local`, `Projection`, `KCut`, `Instances`) over
||| `Gossamer.ABI.ResourceAlgebra`:
|||
|||   * `projCut` (K-2): Endpoint projection commutes with frontier cutting
|||     (`proj p (cutGlobal gl c) = cutLocal (proj p gl) (cutproj p c)`).
|||   * `gradeProj` (K-3): On a projectable choreography, party `p`'s restricted
|||     global grade equals the grade of its endpoint projection.
|||   * `cutProjectable` (K-5): A `p`-consistent frontier cut guarantees
|||     projectability of the truncated global choreography.
|||   * `kcutLoss` (K-1): Parametric K-CUT-LOSS theorem:
|||       `gradeAt p (cutGlobal gl c) = lgrade (cutLocal (proj p gl) (cutproj p c))`
|||   * `K-6`: Discharged at all three Groove operational grades:
|||       1. `kcutLossLoss`    (`LossGrade` — structured information loss)
|||       2. `kcutLossMaxPlus` (`MaxPlusGrade` — worst-case latency budget)
|||       3. `kcutLossHWM`     (`HWMGrade` — high-water-mark buffer occupancy)
|||
||| Lives in `gossamer-groove.ipkg` (depends on `gossamer-abi`).
||| Zero believe_me, zero postulate, zero assert_total. %default total.

module Gossamer.ABI.GrooveChoreography

import Data.Nat
import public Decidable.Equality
import Gossamer.ABI.Types
import Gossamer.ABI.Groove
import public Gossamer.ABI.ResourceAlgebra

%default total

--------------------------------------------------------------------------------
-- 1. Parties and Roles (Choreographic/Party.agda)
--------------------------------------------------------------------------------

||| A choreography party identifier (e.g., 0 = WebView Client, 1 = Groove Host, 2 = Peer Service).
public export
Party : Type
Party = Nat

||| The role party `p` plays in a directed message/choice `s -> r`.
public export
data Role : (p, s, r : Party) -> Type where
  Sender   : p = s -> Role p s r
  Receiver : Not (p = s) -> p = r -> Role p s r
  Outside  : Not (p = s) -> Not (p = r) -> Role p s r

||| Classify party `p` in interaction `s -> r` (`Sender` takes precedence when `s = r`).
public export
role : (p, s, r : Party) -> Role p s r
role p s r with (decEq p s)
  role p s r | Yes e = Sender e
  role p s r | No ne with (decEq p r)
    role p s r | No ne | Yes e  = Receiver ne e
    role p s r | No ne | No ne' = Outside ne ne'

--------------------------------------------------------------------------------
-- 2. Graded Global Types & Cuts (Choreographic/Global.agda)
--------------------------------------------------------------------------------

||| A graded multiparty choreography.
public export
data Global : Type -> Type where
  End    : Global g
  Msg    : (s, r : Party) -> g -> Global g -> Global g
  Choice : (s, r : Party) -> g -> Global g -> Global g -> Global g

||| Global grade accumulation across the choreography.
public export
grade : ResourceAlgebra g => Global g -> g
grade End                = oneG
grade (Msg _ _ x gl)     = otimes x (grade gl)
grade (Choice _ _ x l r) = otimes x (oplus (grade l) (grade r))

||| Share of an interaction's grade experienced by `p`.
public export
at : ResourceAlgebra g => Role p s r -> g -> g
at (Sender _)     x = x
at (Receiver _ _) x = x
at (Outside _ _)  _ = oneG

||| Global accumulation restricted to party `p` (`grade↾`).
public export
gradeAt : ResourceAlgebra g => Party -> Global g -> g
gradeAt p End                = oneG
gradeAt p (Msg s r x gl)     = otimes (at (role p s r) x) (gradeAt p gl)
gradeAt p (Choice s r x l k) = otimes (at (role p s r) x) (oplus (gradeAt p l) (gradeAt p k))

||| Frontier cut through a global choreography.
public export
data Cut : {g : Type} -> Global g -> Type where
  Stop       : {gl : Global g} -> Cut gl
  ContMsg    : {s, r : Party} -> {x : g} -> {gl : Global g} ->
               Cut gl -> Cut (Msg s r x gl)
  ContChoice : {s, r : Party} -> {x : g} -> {l, k : Global g} ->
               Cut l -> Cut k -> Cut (Choice s r x l k)

||| Truncate a global choreography at frontier `c` (`_↾_`).
public export
cutGlobal : (gl : Global g) -> Cut gl -> Global g
cutGlobal _                  Stop             = End
cutGlobal (Msg s r x gl)     (ContMsg c)      = Msg s r x (cutGlobal gl c)
cutGlobal (Choice s r x l k) (ContChoice a b) = Choice s r x (cutGlobal l a) (cutGlobal k b)

--------------------------------------------------------------------------------
-- 3. Graded Local Endpoint Types & Cuts (Choreographic/Local.agda)
--------------------------------------------------------------------------------

||| Graded local endpoint session type.
public export
data Local : Type -> Type where
  LEnd   : Local g
  Send   : Party -> g -> Local g -> Local g
  Recv   : Party -> g -> Local g -> Local g
  Select : Party -> g -> Local g -> Local g -> Local g
  Branch : Party -> g -> Local g -> Local g -> Local g

||| Local grade accumulated along an endpoint's timeline.
public export
lgrade : ResourceAlgebra g => Local g -> g
lgrade LEnd             = oneG
lgrade (Send _ x l)     = otimes x (lgrade l)
lgrade (Recv _ x l)     = otimes x (lgrade l)
lgrade (Select _ x l k) = otimes x (oplus (lgrade l) (lgrade k))
lgrade (Branch _ x l k) = otimes x (oplus (lgrade l) (lgrade k))

||| Frontier cut through a local endpoint type.
public export
data LCut : {g : Type} -> Local g -> Type where
  LStop      : {l : Local g} -> LCut l
  ContSend   : {q : Party} -> {x : g} -> {l : Local g} -> LCut l -> LCut (Send q x l)
  ContRecv   : {q : Party} -> {x : g} -> {l : Local g} -> LCut l -> LCut (Recv q x l)
  ContSelect : {q : Party} -> {x : g} -> {l, k : Local g} ->
               LCut l -> LCut k -> LCut (Select q x l k)
  ContBranch : {q : Party} -> {x : g} -> {l, k : Local g} ->
               LCut l -> LCut k -> LCut (Branch q x l k)

||| Truncate a local endpoint at frontier `c` (`_↾ₗ_`).
public export
cutLocal : (l : Local g) -> LCut l -> Local g
cutLocal _                LStop            = LEnd
cutLocal (Send q x l)     (ContSend c)     = Send q x (cutLocal l c)
cutLocal (Recv q x l)     (ContRecv c)     = Recv q x (cutLocal l c)
cutLocal (Select q x l k) (ContSelect a b) = Select q x (cutLocal l a) (cutLocal k b)
cutLocal (Branch q x l k) (ContBranch a b) = Branch q x (cutLocal l a) (cutLocal k b)

--------------------------------------------------------------------------------
-- 4. Endpoint Projection & Consistency (Choreographic/Projection.agda)
--------------------------------------------------------------------------------

public export
projMsg : {s, r : Party} -> Role p s r -> g -> Local g -> Local g
projMsg {r} (Sender _)     x l = Send r x l
projMsg {s} (Receiver _ _) x l = Recv s x l
projMsg     (Outside _ _)  _ l = l

public export
projChoice : {s, r : Party} -> Role p s r -> g -> Local g -> Local g -> Local g
projChoice {r} (Sender _)     x l k = Select r x l k
projChoice {s} (Receiver _ _) x l k = Branch s x l k
projChoice     (Outside _ _)  _ l _ = l

||| Project global choreography `gl` onto party `p`'s local endpoint.
public export
proj : Party -> Global g -> Local g
proj p End                = LEnd
proj p (Msg s r x gl)     = projMsg (role p s r) x (proj p gl)
proj p (Choice s r x l k) = projChoice (role p s r) x (proj p l) (proj p k)

||| Plain merge obligation for non-participating parties.
public export
Merge : (p : Party) -> Role p s r -> Global g -> Global g -> Type
Merge p (Sender _)     _ _ = ()
Merge p (Receiver _ _) _ _ = ()
Merge p (Outside _ _)  l k = proj p l = proj p k

||| Projectability of `gl` for party `p`.
public export
data Projectable : (p : Party) -> Global g -> Type where
  PEnd    : Projectable p End
  PMsg    : {s, r : Party} -> {x : g} -> {gl : Global g} ->
            Projectable p gl -> Projectable p (Msg s r x gl)
  PChoice : {s, r : Party} -> {x : g} -> {l, k : Global g} ->
            Projectable p l -> Projectable p k -> Merge p (role p s r) l k ->
            Projectable p (Choice s r x l k)

public export
cutprojMsg : {s, r : Party} -> {x : g} -> {l : Local g} ->
             (rho : Role p s r) -> LCut l -> LCut (projMsg rho x l)
cutprojMsg (Sender _)     c = ContSend c
cutprojMsg (Receiver _ _) c = ContRecv c
cutprojMsg (Outside _ _)  c = c

public export
cutprojChoice : {s, r : Party} -> {x : g} -> {l, k : Local g} ->
                (rho : Role p s r) -> LCut l -> LCut k -> LCut (projChoice rho x l k)
cutprojChoice (Sender _)     a b = ContSelect a b
cutprojChoice (Receiver _ _) a b = ContBranch a b
cutprojChoice (Outside _ _)  a _ = a

||| Project a global frontier `c` onto party `p`'s local endpoint.
public export
cutproj : {gl : Global g} -> (p : Party) -> Cut gl -> LCut (proj p gl)
cutproj                          p Stop             = LStop
cutproj {gl = Msg s r x gl'}     p (ContMsg c)      = cutprojMsg (role p s r) (cutproj p c)
cutproj {gl = Choice s r x l k}  p (ContChoice a b) =
  cutprojChoice (role p s r) (cutproj p a) (cutproj p b)

||| A global frontier `c` is consistent for `p` when plain merge holds on the
||| truncated branches of every choice `p` does not participate in.
public export
data Consistent : (p : Party) -> {gl : Global g} -> Cut gl -> Type where
  CStop   : {gl : Global g} -> Consistent p (Stop {gl})
  CMsg    : {s, r : Party} -> {x : g} -> {gl : Global g} -> {c : Cut gl} ->
            Consistent p c -> Consistent p (ContMsg {s} {r} {x} c)
  CChoice : {s, r : Party} -> {x : g} -> {l, k : Global g} ->
            {a : Cut l} -> {b : Cut k} ->
            Consistent p a -> Consistent p b ->
            Merge p (role p s r) (cutGlobal l a) (cutGlobal k b) ->
            Consistent p (ContChoice {s} {r} {x} a b)

--------------------------------------------------------------------------------
-- 5. Keystone K-CUT-LOSS Theorems (Choreographic/KCut.agda)
--------------------------------------------------------------------------------

projCutMsg : {s, r : Party} -> (rho : Role p s r) -> (x : g) -> (l : Local g) -> (c : LCut l) ->
             projMsg rho x (cutLocal l c) = cutLocal (projMsg rho x l) (cutprojMsg {x} rho c)
projCutMsg (Sender _)     _ _ _ = Refl
projCutMsg (Receiver _ _) _ _ _ = Refl
projCutMsg (Outside _ _)  _ _ _ = Refl

projCutChoice : {s, r : Party} -> (rho : Role p s r) -> (x : g) -> (l, k : Local g) ->
                (a : LCut l) -> (b : LCut k) ->
                projChoice rho x (cutLocal l a) (cutLocal k b)
              = cutLocal (projChoice rho x l k) (cutprojChoice {x} rho a b)
projCutChoice (Sender _)     _ _ _ _ _ = Refl
projCutChoice (Receiver _ _) _ _ _ _ _ = Refl
projCutChoice (Outside _ _)  _ _ _ _ _ = Refl

||| K-2 (`proj-cut`): Endpoint projection commutes with cutting (zero algebra laws).
public export
projCut : (p : Party) -> (gl : Global g) -> (c : Cut gl) ->
          proj p (cutGlobal gl c) = cutLocal (proj p gl) (cutproj p c)
projCut p _                  Stop             = Refl
projCut p (Msg s r x gl)     (ContMsg c)      =
  trans (cong (projMsg (role p s r) x) (projCut p gl c))
        (projCutMsg (role p s r) x (proj p gl) (cutproj p c))
projCut p (Choice s r x l k) (ContChoice a b) =
  trans (cong2 (projChoice (role p s r) x) (projCut p l a) (projCut p k b))
        (projCutChoice (role p s r) x (proj p l) (proj p k) (cutproj p a) (cutproj p b))

gradeProjMsg : ResourceAlgebra g => {s, r : Party} ->
               (rho : Role p s r) -> (x : g) -> {y : g} -> {l : Local g} ->
               y = lgrade l -> otimes (at rho x) y = lgrade (projMsg rho x l)
gradeProjMsg (Sender _)         x e = cong (otimes x) e
gradeProjMsg (Receiver _ _)     x e = cong (otimes x) e
gradeProjMsg (Outside _ _) {y}  _ e = trans (seqUnitL y) e

gradeProjChoice : ResourceAlgebra g => {p, s, r : Party} ->
                  (rho : Role p s r) -> (x : g) -> {y1, y2 : g} -> {l, k : Global g} ->
                  y1 = lgrade (proj p l) -> y2 = lgrade (proj p k) ->
                  Merge p rho l k ->
                  otimes (at rho x) (oplus y1 y2) = lgrade (projChoice rho x (proj p l) (proj p k))
gradeProjChoice (Sender _)     x e1 e2 _ = cong (otimes x) (cong2 oplus e1 e2)
gradeProjChoice (Receiver _ _) x e1 e2 _ = cong (otimes x) (cong2 oplus e1 e2)
gradeProjChoice {p} (Outside _ _) _ {y1} {y2} {l} e1 e2 m =
  trans (seqUnitL (oplus y1 y2))
  (trans (cong2 oplus e1 e2)
  (trans (cong (oplus (lgrade (proj p l))) (cong lgrade (sym m)))
         (altIdem (lgrade (proj p l)))))

||| K-3 (`grade-proj`): Restricted global grade equals the grade of the projection.
public export
gradeProj : ResourceAlgebra g => (p : Party) -> (gl : Global g) -> Projectable p gl ->
            gradeAt p gl = lgrade (proj p gl)
gradeProj p End                PEnd               = Refl
gradeProj p (Msg s r x gl)     (PMsg pr)          =
  gradeProjMsg (role p s r) x (gradeProj p gl pr)
gradeProj p (Choice s r x l k) (PChoice pl pk m)  =
  gradeProjChoice (role p s r) x (gradeProj p l pl) (gradeProj p k pk) m

||| K-5 (`cut-projectable`): A consistent cut yields a projectable choreography.
public export
cutProjectable : (p : Party) -> (gl : Global g) -> (c : Cut gl) -> Consistent p c ->
                 Projectable p (cutGlobal gl c)
cutProjectable p _                  Stop             CStop             = PEnd
cutProjectable p (Msg s r x gl)     (ContMsg c)      (CMsg kc)         =
  PMsg (cutProjectable p gl c kc)
cutProjectable p (Choice s r x l k) (ContChoice a b) (CChoice ka kb m) =
  PChoice (cutProjectable p l a ka) (cutProjectable p k b kb) m

||| K-1 (`kcut-loss`): Keystone theorem — for every party `p`, global choreography `gl`,
||| and `p`-consistent frontier `c`, `p`'s restricted global grade up to `c` equals
||| the local grade `p` computes on its projected endpoint up to `cutproj p c`.
public export
kcutLoss : ResourceAlgebra g => (p : Party) -> (gl : Global g) -> (c : Cut gl) ->
           Consistent p c ->
           gradeAt p (cutGlobal gl c) = lgrade (cutLocal (proj p gl) (cutproj p c))
kcutLoss p gl c k =
  trans (gradeProj p (cutGlobal gl c) (cutProjectable p gl c k))
        (cong lgrade (projCut p gl c))

||| Uncut special case (`kcut-loss-full`).
public export
kcutLossFull : ResourceAlgebra g => (p : Party) -> (gl : Global g) -> Projectable p gl ->
               gradeAt p gl = lgrade (proj p gl)
kcutLossFull = gradeProj

--------------------------------------------------------------------------------
-- 6. K-6: Discharged at Groove's Three Operational Grades + Worked Broker
--------------------------------------------------------------------------------

public export
kcutLossLoss : (p : Party) -> (gl : Global LossGrade) -> (c : Cut gl) -> Consistent p c ->
               gradeAt p (cutGlobal gl c) = lgrade (cutLocal (proj p gl) (cutproj p c))
kcutLossLoss = kcutLoss

public export
kcutLossMaxPlus : (p : Party) -> (gl : Global MaxPlusGrade) -> (c : Cut gl) -> Consistent p c ->
                  gradeAt p (cutGlobal gl c) = lgrade (cutLocal (proj p gl) (cutproj p c))
kcutLossMaxPlus = kcutLoss

public export
kcutLossHWM : (p : Party) -> (gl : Global HWMGrade) -> (c : Cut gl) -> Consistent p c ->
              gradeAt p (cutGlobal gl c) = lgrade (cutLocal (proj p gl) (cutproj p c))
kcutLossHWM = kcutLoss

||| Worked 3-party Groove choreography:
||| Party 0 (WebView Client) -> Party 1 (Groove Host Broker) : `a`
||| Party 1 (Groove Host Broker) -> Party 2 (Groove Peer Service) : `b`
||| Party 0 -> Party 2 chooses branch { 2 -> 1 : `c` . End | 2 -> 1 : `c` . End }.
public export
grooveBrokerChoreo : ResourceAlgebra g => (a, b, c : g) -> Global g
grooveBrokerChoreo a b c =
  Msg 0 1 a (Msg 1 2 b (Choice 0 2 oneG (Msg 2 1 c End) (Msg 2 1 c End)))

public export
grooveBrokerCut : ResourceAlgebra g => {a, b, c : g} -> Cut (grooveBrokerChoreo a b c)
grooveBrokerCut = ContMsg (ContMsg (ContChoice Stop Stop))

public export
grooveBrokerProjectable : ResourceAlgebra g => {a, b, c : g} ->
                          Projectable 1 (grooveBrokerChoreo a b c)
grooveBrokerProjectable = PMsg (PMsg (PChoice (PMsg PEnd) (PMsg PEnd) Refl))

public export
grooveBrokerConsistent : ResourceAlgebra g => {a, b, c : g} ->
                         Consistent 1 (grooveBrokerCut {a} {b} {c})
grooveBrokerConsistent = CMsg (CMsg (CChoice CStop CStop Refl))

public export
grooveBrokerKCut : ResourceAlgebra g => (a, b, c : g) ->
                   gradeAt 1 (cutGlobal (grooveBrokerChoreo a b c) (grooveBrokerCut {a} {b} {c}))
                 = lgrade (cutLocal (proj 1 (grooveBrokerChoreo a b c))
                                    (cutproj 1 (grooveBrokerCut {a} {b} {c})))
grooveBrokerKCut a b c =
  kcutLoss 1 (grooveBrokerChoreo a b c) grooveBrokerCut grooveBrokerConsistent

public export
grooveLossFull : gradeAt 1 (grooveBrokerChoreo (Finite 1) (Finite 2) (Finite 5)) = Finite 8
grooveLossFull = Refl

public export
grooveLossAtCut : gradeAt 1 (cutGlobal (grooveBrokerChoreo (Finite 1) (Finite 2) (Finite 5))
                                       GrooveChoreography.grooveBrokerCut) = Finite 3
grooveLossAtCut = Refl

public export
grooveLatencyFull : gradeAt 1 (grooveBrokerChoreo (Val 1) (Val 2) (Val 5)) = Val 8
grooveLatencyFull = Refl

public export
grooveOccupancyFull : peak (gradeAt 1 (grooveBrokerChoreo (MkHWM 1 0 LTEZero)
                                                          (MkHWM 2 0 LTEZero)
                                                          (MkHWM 5 0 LTEZero))) = 5
grooveOccupancyFull = Refl

public export
grooveOccupancyAtCut : peak (gradeAt 1 (cutGlobal (grooveBrokerChoreo (MkHWM 1 0 LTEZero)
                                                                      (MkHWM 2 0 LTEZero)
                                                                      (MkHWM 5 0 LTEZero))
                                                  GrooveChoreography.grooveBrokerCut)) = 2
grooveOccupancyAtCut = Refl
