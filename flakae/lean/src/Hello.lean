def nontail.sum : List Nat -> Nat
  | [] => 0
  | x :: xs => x + sum xs

def tail.sumHelper (soFar : Nat) : List Nat -> Nat
  | [] => soFar
  | x :: xs => sumHelper (soFar + x) xs

def tail.sum (xs : List Nat) : Nat :=
  sumHelper 0 xs

theorem tail_nontail_equiv : nontail.sum = tail.sum := by
  have lemma (xs: List Nat) :
    ∀ n : Nat, n + nontail.sum xs = tail.sumHelper n xs := by
    induction xs with
    | nil => intro n; rfl
    | cons xs_head xs_tail ih =>
      intro n
      simp [nontail.sum, tail.sumHelper]
      rw [<-Nat.add_assoc]
      exact ih (n + xs_head)

  funext xs
  simp [tail.sum]
  rw [<-Nat.zero_add (nontail.sum xs)]
  exact lemma xs 0


example (p q r : Prop) : p ∧ (q ∨ r) ↔ (p ∧ q) ∨ (p ∧ r) := by
  apply Iff.intro
  . intro h
    apply Or.elim (And.right h)
    . intro hq
      apply Or.inl
      apply And.intro
      . exact And.left h
      . exact hq
    . intro hr
      apply Or.inr
      apply And.intro
      . exact And.left h
      . exact hr
  . intro h
    apply Or.elim h
    . intro hpq
      apply And.intro
      . exact And.left hpq
      . apply Or.inl
        exact And.right hpq
    . intro hpr
      apply And.intro
      . exact And.left hpr
      . apply Or.inr
        exact And.right hpr
